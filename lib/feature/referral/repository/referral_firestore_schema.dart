// lib/feature/referral/repository/referral_firestore_schema.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// FIRESTORE COLLECTIONS SCHEMA
/// ═══════════════════════════════════════════════════════════════════════════

/*

📁 referrals/
  └─ {referralId} (auto-generated)
      - referralCode: "JOHN2024XYZ"
      - referrerId: "referrer@email.com"
      - referrerType: "brand" | "fan" | "athlete"
      - refereeId: "newuser@email.com"
      - refereeType: "brand" | "fan" | "athlete"
      - status: "pending" | "completed"
      - createdAt: timestamp
      - completedAt: timestamp?

📁 referral_rewards/
  └─ {rewardId} (auto-generated)
      - userId: "user@email.com"
      - userType: "brand" | "fan" | "athlete"
      - rewardType: "user_referral_points" | "brand_commission"
      - points: 50 (for user referrals)
      - amount: 1000.50 (for brand commissions - in USD)
      - bookingId: "xyz123" (for brand commissions only)
      - referralId: "ref_abc123"
      - status: "pending" | "credited" | "failed"
      - createdAt: timestamp
      - creditedAt: timestamp?
      - failureReason: string?

📁 referral_settings/
  └─ config (single document)
      - pointsPerDollar: 100
      - pointsPerReferral: 50
      - brandCommissionPercentage: 10
      - brandCommissionType: "one_time" | "recurring"
      - enabled: true
      - updatedAt: timestamp
      - updatedBy: "admin@email.com"

📁 user_referral_codes/
  └─ {email} (user's email as doc ID)
      - userId: "user@email.com"
      - userType: "brand" | "fan" | "athlete"
      - referralCode: "JOHN2024XYZ"
      - totalReferrals: 5
      - successfulReferrals: 3
      - totalPointsEarned: 150
      - totalCommissionEarned: 5000.00
      - createdAt: timestamp
      - updatedAt: timestamp

📁 brand_commission_tracking/
  └─ {trackingId} (auto-generated)
      - brandId: "brand@email.com"
      - referrerId: "referrer@email.com"
      - referrerType: "brand" | "fan" | "athlete"
      - bookingId: "xyz123"
      - dealAmount: 10000.00
      - commissionPercentage: 10
      - commissionAmount: 1000.00
      - dealApprovedAt: timestamp
      - commissionPaidAt: timestamp?
      - status: "pending" | "paid" | "failed"
      - isFirstDeal: true
      - createdAt: timestamp

*/
