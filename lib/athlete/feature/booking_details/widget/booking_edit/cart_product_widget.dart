import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class CartServiceWidget extends StatelessWidget {
  final CartModel? cart;
  final int cartIndex;
  final bool disableQuantityButton;
  final BookingEditType bookingEditType;

  const CartServiceWidget({
    super.key,
    required this.cart,
    required this.cartIndex,
    required this.disableQuantityButton,
    required this.bookingEditType,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingEditController>(
      builder: (bookingEditController) {
        return Container(
          height: 80.0,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              Positioned(
                right: Get.find<LocalizationController>().isLtr ? 22 : null,
                left: Get.find<LocalizationController>().isLtr ? null : 22,
                child: Image.asset(Images.servicemanDelete, width: 22.0),
              ),

              bookingEditController.cartList.length > 1 &&
                      bookingEditType == BookingEditType.regular
                  ? Dismissible(
                      key: UniqueKey(),
                      onDismissed: (DismissDirection direction) =>
                          bookingEditController.removeCartItem(cartIndex),
                      child: CartItemView(
                        bookingEditController: bookingEditController,
                        cart: cart,
                        cartIndex: cartIndex,
                        disableQuantityButton: disableQuantityButton,
                        bookingEditType: bookingEditType,
                      ),
                    )
                  : CartItemView(
                      bookingEditController: bookingEditController,
                      cart: cart,
                      cartIndex: cartIndex,
                      disableQuantityButton: disableQuantityButton,
                      bookingEditType: bookingEditType,
                    ),
            ],
          ),
        );
      },
    );
  }
}

class CartItemView extends StatelessWidget {
  final BookingEditController bookingEditController;
  final CartModel? cart;
  final int cartIndex;
  final bool disableQuantityButton;
  final BookingEditType bookingEditType;
  const CartItemView({
    super.key,
    required this.bookingEditController,
    this.cart,
    required this.cartIndex,
    required this.disableQuantityButton,
    required this.bookingEditType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
        horizontal: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.white.withValues(alpha: .2)),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: context.customThemeColors.lightShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              width: ResponsiveHelper.isMobile(context)
                  ? Get.width / 1.8
                  : Get.width / 4,
              child: Row(
                children: [
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImage(
                      image: '${cart?.serviceThumbnail}',
                      height: 65,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cart?.serviceName ?? "",
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),

                        if (cart?.variantKey != null)
                          SizedBox(
                            width: Get.width * 0.4,
                            child: Text(
                              cart?.variantKey ?? "",
                              style: robotoMedium.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: .6),
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 5),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice(
                              double.tryParse(
                                cart?.totalCost?.toString() ?? "0",
                              ),
                            ),
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withValues(alpha: .6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!disableQuantityButton)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  if (cart!.quantity! > 1)
                    QuantityButton(
                      onTap: () {
                        bookingEditController.updateCartItemQuantity(
                          cart!,
                          cartIndex,
                          increment: false,
                        );
                      },
                      isIncrement: false,
                    ),
                  if (cart!.quantity == 1 &&
                      bookingEditController.cartList.length > 1 &&
                      bookingEditType == BookingEditType.regular)
                    InkWell(
                      onTap: () {
                        showCustomDialog(
                          child: ConfirmationDialog(
                            icon: Images.servicemanDelete,
                            description:
                                'are_you_sure_to_delete_this_service'.tr,
                            onYesPressed: () {
                              bookingEditController.removeCartItem(cartIndex);
                              Get.back();
                            },
                          ),
                          useSafeArea: false,
                          barrierDismissible: true,
                        );
                      },
                      child: Container(
                        height: 22,
                        width: 22,
                        margin: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        child: Icon(
                          Icons.delete_forever,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  Text(
                    cart!.quantity.toString(),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                    ),
                  ),
                  QuantityButton(
                    onTap: () {
                      bookingEditController.updateCartItemQuantity(
                        cart!,
                        cartIndex,
                        increment: true,
                      );
                    },
                    isIncrement: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
