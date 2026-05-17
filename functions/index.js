// functions/index.js
//
// Firebase Cloud Functions v2 (Node.js 22)
//

const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onDocumentWritten} = require("firebase-functions/v2/firestore");
const {onCall} = require("firebase-functions/v2/https");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// Config
const getFlwSecret = () =>
  process.env.FLW_SECRET_KEY || "";
const getFlwCurrency = () => "NGN";

// 1. processMonthlyDonations - Runs 1st of each month at 8am Lagos time
exports.processMonthlyDonations = onSchedule({
  schedule: "0 8 1 * *",
  timeZone: "Africa/Lagos",
  memory: "512MiB",
  timeoutSeconds: 540,
}, async () => {
  logger.info("[Monthly] Starting monthly donation run");

  const now = admin.firestore.Timestamp.now();

  const snap = await db
      .collection("campaign_subscriptions")
      .where("status", "==", "active")
      .where("nextChargeDate", "<=", now)
      .get();

  if (snap.empty) {
    logger.info("[Monthly] No subscriptions due today");
    return;
  }

  logger.info(`[Monthly] Processing ${snap.size} subscription(s)`);

  const docs = snap.docs;
  const BATCH_SIZE = 10;

  for (let i = 0; i < docs.length; i += BATCH_SIZE) {
    const batch = docs.slice(i, i + BATCH_SIZE);
    await Promise.all(batch.map((doc) => chargeSubscription(doc)));
  }

  logger.info("[Monthly] Run complete");
});

async function chargeSubscription(doc) {
  const sub = doc.data();
  const subId = doc.id;
  const txRef = `monthly_${subId}_${Date.now()}`;

  try {
    logger.info(`[Monthly] Charging sub ${subId}`);

    const res = await axios.post(
        "https://api.flutterwave.com/v3/tokenized-charges",
        {
          token: sub.flwToken,
          currency: getFlwCurrency(),
          country: "NG",
          amount: sub.amount,
          email: sub.donorEmail,
          tx_ref: txRef,
          narration: `Monthly donation to ${sub.campaignTitle}`,
        },
        {
          headers: {
            "Authorization": `Bearer ${getFlwSecret()}`,
            "Content-Type": "application/json",
          },
          timeout: 15000,
        },
    );

    const {status, data} = res.data;
    const charged = status === "success" && data?.status === "successful";

    if (charged) {
      await onChargeSuccess(sub, subId, txRef, data?.id?.toString() ?? txRef);
    } else {
      await onChargeFailure(sub, subId, res.data?.message ?? "Charge declined");
    }
  } catch (err) {
    logger.error(`[Monthly] Error charging ${subId}:`, err.message);
    await onChargeFailure(sub, subId, err.message ?? "Network error");
  }
}

async function onChargeSuccess(sub, subId, txRef, transactionId) {
  logger.info(`[Monthly] Success for ${subId}`);

  const batch = db.batch();
  const now = admin.firestore.FieldValue.serverTimestamp();
  const nextCharge = nextMonthSameDay();

  batch.update(db.collection("campaign_subscriptions").doc(subId), {
    lastChargedAt: now,
    nextChargeDate: admin.firestore.Timestamp.fromDate(nextCharge),
    failureCount: 0,
    failureReason: null,
    status: "active",
  });

  const donationRef = db.collection("campaign_donations").doc();
  batch.set(donationRef, {
    campaignId: sub.campaignId,
    campaignTitle: sub.campaignTitle,
    athleteId: sub.athleteId,
    athleteIdLower: sub.athleteId,
    athleteName: sub.athleteName ?? "",
    donorId: sub.donorId,
    donorName: sub.donorName,
    donorEmail: sub.donorEmail,
    isAnonymous: sub.isAnonymous,
    amount: sub.amount,
    frequency: "monthly",
    status: "completed",
    transactionRef: txRef,
    flwTransactionId: transactionId,
    isRecurringCharge: true,
    message: null,
    createdAt: now,
    processedAt: now,
  });

  const campaignRef = db.collection("campaigns").doc(sub.campaignId);
  batch.update(campaignRef, {
    raisedAmount: admin.firestore.FieldValue.increment(sub.amount),
    donorCount: admin.firestore.FieldValue.increment(1),
    updatedAt: now,
  });

  if (sub.donorId) {
    const donorRef = campaignRef.collection("donors").doc(sub.donorId);
    batch.set(donorRef, {
      donorName: sub.donorName,
      isAnonymous: sub.isAnonymous,
      totalAmount: admin.firestore.FieldValue.increment(sub.amount),
      donationCount: admin.firestore.FieldValue.increment(1),
      lastFrequency: "monthly",
      lastDonatedAt: now,
    }, {merge: true});
  }

  batch.set(db.collection("athlete_profiles").doc(sub.athleteId), {
    totalCampaignEarnings: admin.firestore.FieldValue.increment(sub.amount),
    pendingCampaignWithdrawal: admin.firestore.FieldValue.increment(sub.amount),
    updatedAt: now,
  }, {merge: true});

  await batch.commit();

  const currency = "₦";
  const fmtAmount = fmt(sub.amount);
  const nextFmt = `${nextCharge.getDate()}/${nextCharge.getMonth() + 1}/${nextCharge.getFullYear()}`;

  await Promise.all([
    enqueueNotification({
      recipientUid: sub.donorId,
      recipientType: "donor",
      title: "Monthly Donation Processed ✅",
      body: `${currency}${fmtAmount} donated to "${sub.campaignTitle}". Next charge: ${nextFmt}.`,
      data: {type: "monthly_charged", screen: "manage_subscriptions"},
    }),
    enqueueNotification({
      recipientUid: sub.athleteId,
      recipientType: "athlete",
      title: "Monthly Donation Received 💚",
      body: `${sub.isAnonymous ? "Anonymous Hero" : sub.donorName}'s monthly ${currency}${fmtAmount} donation to "${sub.campaignTitle}" was processed.`,
      data: {type: "monthly_received", screen: "campaign_detail"},
    }),
  ]);

  try {
    await checkMilestones(sub.campaignId, sub.athleteId, sub.campaignTitle);
  } catch (e) {
    logger.warn("[Monthly] Milestone check error:", e.message);
  }
}

async function onChargeFailure(sub, subId, reason) {
  logger.warn(`[Monthly] Failed for ${subId}: ${reason}`);

  const currentCount = (sub.failureCount ?? 0) + 1;
  const shouldPause = currentCount >= 3;

  await db.collection("campaign_subscriptions").doc(subId).update({
    failureCount: currentCount,
    failureReason: reason,
    status: shouldPause ? "paused" : "active",
  });

  if (sub.donorId) {
    const currency = "₦";
    await enqueueNotification({
      recipientUid: sub.donorId,
      recipientType: "donor",
      title: shouldPause ? "Monthly Donation Paused ⚠️" : "Monthly Charge Failed ❌",
      body: shouldPause ?
        `We couldn't charge your card for "${sub.campaignTitle}" after 3 attempts. Please update your payment method.` :
        `We couldn't process your ${currency}${fmt(sub.amount)} donation to "${sub.campaignTitle}". We'll retry next month.`,
      data: {
        type: "charge_failed",
        isPaused: String(shouldPause),
        screen: "manage_subscriptions",
      },
    });
  }
}

// 2. deliverNotifications - Firestore trigger
exports.deliverNotifications = onDocumentCreated("notification_queue/{docId}", async (event) => {
  const snap = event.data;
  if (!snap) return;

  const n = snap.data();
  if (!n || n.status !== "pending") return;

  try {
    const fcmToken = await resolveFcmToken(n.recipientUid, n.recipientType);

    if (!fcmToken) {
      logger.warn(`[Notif] No FCM token for ${n.recipientType} ${n.recipientUid}`);
      await snap.ref.update({status: "no_token"});
      return;
    }

    const message = {
      token: fcmToken,
      notification: {title: n.title, body: n.body},
      data: n.data ?? {},
      android: {
        notification: {
          channelId: "campaign_donations",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: {sound: "default", badge: 1},
        },
      },
    };

    await admin.messaging().send(message);

    await snap.ref.update({
      status: "sent",
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info(`[Notif] Sent to ${n.recipientUid}: ${n.title}`);
  } catch (err) {
    logger.error("[Notif] Delivery error:", err.message);
    await snap.ref.update({status: "failed", error: err.message});
  }
});

async function resolveFcmToken(uid, type) {
  try {
    if (!uid) return null;

    // ✅ athlete tokens live in "athletes", brands/fans live in "users"
    const col = type === "athlete" ? "athletes" : "users";

    const doc = await db.collection(col).doc(uid).get();
    return doc.exists ? (doc.data().fcmToken ?? null) : null;
  } catch {
    return null;
  }
}

async function checkMilestones(campaignId, athleteId, campaignTitle) {
  const snap = await db.collection("campaigns").doc(campaignId).get();
  if (!snap.exists) return;

  const d = snap.data();
  const raised = d.raisedAmount ?? 0;
  const milestones = d.milestones ?? [];

  let changed = false;
  const updated = milestones.map((m) => {
    if (!m.isUnlocked && raised >= m.targetAmount) {
      changed = true;
      return {...m, isUnlocked: true, unlockedAt: new Date()};
    }
    return m;
  });

  if (!changed) return;

  await db.collection("campaigns").doc(campaignId).update({
    milestones: updated,
    ...(updated.every((m) => m.isUnlocked) ? {status: "completed"} : {}),
  });

  const newlyUnlocked = updated.filter((m, i) => m.isUnlocked && !milestones[i].isUnlocked);
  for (const m of newlyUnlocked) {
    await enqueueNotification({
      recipientUid: athleteId,
      recipientType: "athlete",
      title: "Milestone Unlocked! 🏅",
      body: `"${campaignTitle}" just hit "${m.title}" — ₦${fmt(m.targetAmount)} raised!`,
      data: {type: "milestone_unlocked", screen: "campaign_detail"},
    });
  }
}

async function enqueueNotification({recipientUid, recipientType, title, body, data}) {
  if (!recipientUid) return;
  try {
    await db.collection("notification_queue").add({
      recipientUid,
      recipientType,
      title,
      body,
      data: data ?? {},
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      sentAt: null,
    });
  } catch (e) {
    logger.warn("[Notif] Enqueue error:", e.message);
  }
}

function nextMonthSameDay() {
  const now = new Date();
  const next = new Date(now);
  next.setMonth(now.getMonth() + 1);
  if (next.getDate() !== now.getDate()) {
    next.setDate(0);
  }
  return next;
}

function fmt(v) {
  if (v >= 1000000) return `${(v / 1000000).toFixed(1)}M`;
  if (v >= 1000) return `${(v / 1000).toFixed(1)}K`;
  return String(Math.round(v));
}

// ═══════════════════════════════════════════════════════════════════════════
// ATHLETE WELCOME PUSH NOTIFICATION (v2 callable)
// ═══════════════════════════════════════════════════════════════════════════

exports.sendWelcomePushNotification = onCall(async (request) => {
  const {email, firstName, fieldOfSport} = request.data;

  if (!email || !firstName || !fieldOfSport) {
    throw new Error("Missing required fields: email, firstName, fieldOfSport");
  }

  const docId = email.toLowerCase().trim();

  // Get athlete's FCM token from Firestore
  const athleteDoc = await db.collection("athletes").doc(docId).get();

  if (!athleteDoc.exists) {
    throw new Error("Athlete not found in Firestore");
  }

  const athleteData = athleteDoc.data();
  const fcmToken = athleteData.fcmToken;

  if (!fcmToken || fcmToken === "@" || fcmToken === "") {
    logger.warn(`[AthleteWelcome] No FCM token for athlete: ${docId}`);
    return {
      success: false,
      message: "No FCM token available. Push skipped — email still sent.",
    };
  }

  const message = {
    token: fcmToken,
    notification: {
      title: `Welcome to AfriEndorse, ${firstName}! 🎉`,
      body: `Your ${fieldOfSport} profile is ready. Start connecting with brands!`,
    },
    data: {
      type: "welcome_notification",
      screen: "dashboard",
      email: email,
    },
    android: {
      notification: {
        channelId: "welcome_notifications",
        priority: "high",
        defaultSound: true,
        defaultVibrateTimings: true,
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
          contentAvailable: true,
        },
      },
    },
  };

  try {
    await admin.messaging().send(message);

    // Log push sent status in Firestore
    await athleteDoc.ref.update({
      welcomePushSent: true,
      welcomePushSentAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info(`[AthleteWelcome] Push sent to athlete: ${docId}`);

    return {
      success: true,
      message: "Welcome push notification sent successfully",
    };
  } catch (error) {
    logger.error(`[AthleteWelcome] FCM send error for ${docId}:`, error.message);
    throw new Error(`Failed to send push notification: ${error.message}`);
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// BRAND/FAN WELCOME PUSH NOTIFICATION (v2 callable)
// ═══════════════════════════════════════════════════════════════════════════

exports.sendBrandFanWelcomePush = onCall(async (request) => {
  const {email, firstName, userType, brandName} = request.data;

  if (!email || !firstName || !userType) {
    throw new Error("Missing required fields: email, firstName, userType");
  }

  const docId = email.toLowerCase().trim();

  // Get user's FCM token from Firestore (users collection)
  const userDoc = await db.collection("users").doc(docId).get();

  if (!userDoc.exists) {
    throw new Error("User not found in Firestore");
  }

  const userData = userDoc.data();
  const fcmToken = userData.fcmToken;

  if (!fcmToken || fcmToken === "@" || fcmToken === "") {
    logger.warn(`[BrandFanWelcome] No FCM token for user: ${docId}`);
    return {
      success: false,
      message: "No FCM token available. Push skipped — email still sent.",
    };
  }

  const displayName = userType === "brand" ? (brandName || firstName) : firstName;
  const isBrand = userType === "brand";

  const title = isBrand
    ? `Welcome to AfriEndorse, ${displayName}! 🚀`
    : `Welcome to AfriEndorse, ${firstName}! 🎉`;

  const body = isBrand
    ? "Your brand profile is ready. Start discovering athletes and launching campaigns!"
    : "Start following athletes, supporting campaigns, and enjoying exclusive content!";

  const message = {
    token: fcmToken,
    notification: {
      title: title,
      body: body,
    },
    data: {
      type: "welcome_notification",
      screen: isBrand ? "brand_dashboard" : "fan_home",
      email: email,
      userType: userType,
    },
    android: {
      notification: {
        channelId: "welcome_notifications",
        priority: "high",
        defaultSound: true,
        defaultVibrateTimings: true,
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
          contentAvailable: true,
        },
      },
    },
  };

  try {
    await admin.messaging().send(message);

    // Log push sent status in Firestore
    await userDoc.ref.update({
      welcomePushSent: true,
      welcomePushSentAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info(`[BrandFanWelcome] Push sent to ${userType}: ${docId}`);

    return {
      success: true,
      message: "Welcome push notification sent successfully",
    };
  } catch (error) {
    logger.error(`[BrandFanWelcome] FCM send error for ${docId}:`, error.message);
    throw new Error(`Failed to send push notification: ${error.message}`);
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// DEAL APPROVAL WORKFLOW (Brand Approve/Decline + 72h Auto-Approve)
// Uses MySQL TRACK endpoint to fetch OTP without backend changes.
// ═══════════════════════════════════════════════════════════════════════════

const DEAL_APPROVAL_HOURS_MS = 72 * 60 * 60 * 1000;
const BASE_URL = "https://admin.afriendorse.com";
const TRACK_URL_TEMPLATE =
  `${BASE_URL}/api/v1/customer/booking/track/{readableId}`;

function cleanOtp(v) {
  if (!v) return null;
  const s = String(v).replace("null", "").trim();
  return s.length === 6 ? s : null;
}

async function fetchOtpViaTrack(readableId, phone) {
  const url = TRACK_URL_TEMPLATE.replace("{readableId}", readableId);

  const res = await axios.post(
    url,
    {phone: phone},
    {
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      timeout: 20000,
    }
  );

  // Your mobile parses response.body['content'] then 'booking_otp'
  const otp =
    res.data?.content?.booking_otp ??
    res.data?.content?.bookingOtp;

  return cleanOtp(otp);
}

/**
 * Firestore Trigger:
 * - When deal_approvals/{bookingId} becomes "requested": set expiresAt = requestedAt + 72h
 * - Also sends push notifications (optional but recommended)
 */
exports.dealApprovalOnWrite = onDocumentWritten(
  {
    document: "deal_approvals/{bookingId}",
    memory: "256MiB",
  },
  async (event) => {
    const afterSnap = event.data?.after;
    const beforeSnap = event.data?.before;

    if (!afterSnap || !afterSnap.exists) return;

    const after = afterSnap.data() || {};
    const before = (beforeSnap && beforeSnap.exists) ? (beforeSnap.data() || {}) : {};

    const beforeStatus = String(before.status || "");
    const afterStatus = String(after.status || "");

    const bookingId = event.params.bookingId;

    // ── 1) Set/refresh expiry when requested ────────────────────────────
    if (afterStatus === "requested" && after.requestedAt) {
      const requestedAt = after.requestedAt.toDate();
      const computedExpiresAt = admin.firestore.Timestamp.fromDate(
        new Date(requestedAt.getTime() + DEAL_APPROVAL_HOURS_MS)
      );

      const currentExpiresAt = after.expiresAt;

      const needsUpdate =
        !currentExpiresAt ||
        (currentExpiresAt.toMillis && currentExpiresAt.toMillis() !== computedExpiresAt.toMillis());

      if (needsUpdate) {
        await afterSnap.ref.set(
          {
            expiresAt: computedExpiresAt,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true}
        );
      }
    }

    // ── 2) Status-change notifications (reuses your notification_queue) ──
    if (beforeStatus !== afterStatus) {
      const brandEmail = (after.brandEmail || "").toLowerCase().trim();
      const athleteEmail = (after.athleteEmail || "").toLowerCase().trim();

      // When athlete requests -> notify brand
      if (afterStatus === "requested" && brandEmail) {
        await enqueueNotification({
          recipientUid: brandEmail,
          recipientType: "brand",
          title: "Approval Requested",
          body: `An athlete requested approval to complete Deal #${bookingId}.`,
          data: {type: "deal_approval_requested", bookingId},
        });
      }

      // When brand approves/declines/auto-approve -> notify athlete
      if (
        (afterStatus === "approved" ||
          afterStatus === "declined" ||
          afterStatus === "auto_approved") &&
        athleteEmail
      ) {
        const title =
          afterStatus === "declined"
            ? "Changes Requested"
            : "Deal Approved";

        const body =
          afterStatus === "declined"
            ? (after.reason ? String(after.reason) : "Brand declined your request. Please review and resubmit.")
            : "You can now receive payment by completing the deal.";

        await enqueueNotification({
          recipientUid: athleteEmail,
          recipientType: "athlete",
          title,
          body,
          data: {type: "deal_approval_update", bookingId, status: afterStatus},
        });
      }
    }
  }
);

/**
 * Scheduler:
 * Every 10 minutes:
 * - Find requested approvals whose expiresAt <= now
 * - Fetch OTP via MySQL TRACK endpoint (readableId + brandPhone)
 * - Write status=auto_approved and otp into Firestore
 */
exports.autoApproveExpiredDeals = onSchedule(
  {
    schedule: "every 10 minutes",
    timeZone: "Africa/Lagos",
    memory: "512MiB",
    timeoutSeconds: 540,
  },
  async () => {
    const now = admin.firestore.Timestamp.now();

    // NOTE: Firestore will likely require a composite index for:
    // status == requested AND expiresAt <= now
    const snap = await db
      .collection("deal_approvals")
      .where("status", "==", "requested")
      .where("expiresAt", "<=", now)
      .get();

    if (snap.empty) return;

    logger.info(`[DealApproval] Auto-approving ${snap.size} expired request(s)`);

    for (const doc of snap.docs) {
      const d = doc.data() || {};
      const bookingId = doc.id;

      const readableId = String(d.readableId || "").trim();
      const brandPhone = String(d.brandPhone || "").trim();

      if (!readableId || !brandPhone) {
        logger.warn(`[DealApproval] Missing readableId/brandPhone for ${bookingId}`);
        continue;
      }

      let otp = null;
      try {
        otp = await fetchOtpViaTrack(readableId, brandPhone);
      } catch (e) {
        logger.error(`[DealApproval] OTP fetch failed for ${bookingId}:`, e.message);
      }

      // If OTP not available yet, skip (next run will retry)
      if (!otp) {
        logger.warn(`[DealApproval] OTP unavailable for ${bookingId}. Will retry.`);
        continue;
      }

      await doc.ref.set(
        {
          status: "auto_approved",
          otp: otp,
          otpSetAt: now,
          decidedAt: now,
          updatedAt: now,
        },
        {merge: true}
      );
    }
  }
);