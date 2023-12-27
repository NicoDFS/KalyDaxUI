import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../helpers/sizes_helpers.dart';
import 'spacers.dart';
import 'package:kalydax_redux/account/account_state.dart';
import 'package:kalydax_redux/markets/markets_state.dart';
import 'package:kalydax_redux/types.dart';
import '../helpers/orderbook_helper.dart';
import '../helpers/volume_helper.dart';
import '../utils/text_input_formatter.dart';
import '../utils/theme.dart';
import 'account_screen_inputs.dart';
import 'switch_button.dart';

class OrderPlacementScreenWithButton extends StatefulWidget {
  const OrderPlacementScreenWithButton(
      {Key key,
      // this.side,
      this.price,
      this.userSession,
      this.amount,
      this.limitSelected,
      this.selectedMarket,
      this.balances,
      this.popAfterOrder = true,
      this.switchBgColor,
      this.onPlaceOrder,
      this.isAuthourized})
      : super(key: key);

  final UserSessionState userSession;
  // final orderSide side;
  final double price;
  final double amount;
  final bool limitSelected;
  final MarketItemState selectedMarket;
  final List<UserBalanceItemState> balances;
  final Function(String barongSession, String market, orderSide side,
      orderType type, double amount,
      [double price]) onPlaceOrder;
  final Color switchBgColor;
  final bool popAfterOrder;
  final bool isAuthourized;

  @override
  _OrderPlacementScreenWithButtonState createState() =>
      _OrderPlacementScreenWithButtonState();
}

class _OrderPlacementScreenWithButtonState
    extends State<OrderPlacementScreenWithButton> {
  double price;
  double amount;
  bool limitSelected;
  double total;
  double baseBalance;
  double quoteBalance;
  bool sellSelected;
  orderSide side;

  final priceController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    priceController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OrderPlacementScreenWithButton oldWidget) {
    // TODO: implement didUpdateWidget;
    if (oldWidget.selectedMarket.id != widget.selectedMarket.id) {
      setState(
        () {
          price = widget.selectedMarket.ticker.last;
          amount = widget.amount == null ? null : widget.amount;
          baseBalance = widget.balances.isNotEmpty
              ? widget.balances
                  .firstWhere(
                    (element) =>
                        element.currency.id ==
                        widget.selectedMarket.baseUnit.id,
                  )
                  .balance
              : 0.0;
          quoteBalance = widget.balances.isNotEmpty
              ? widget.balances
                  .firstWhere(
                    (element) =>
                        element.currency.id ==
                        widget.selectedMarket.quoteUnit.id,
                  )
                  .balance
              : 0.0;
          priceController.text = widget.selectedMarket.ticker.last.toString();
          amountController.text = '';
        },
      );
    } else if (!limitSelected) {
      setState(
        () {
          price = widget.selectedMarket.ticker.last;
          priceController.text = widget.selectedMarket.ticker.last
              .toStringAsFixed(widget.selectedMarket.pricePrecision);
          baseBalance = widget.balances.isNotEmpty
              ? widget.balances
                  .firstWhere(
                    (element) =>
                        element.currency.id ==
                        widget.selectedMarket.baseUnit.id,
                  )
                  .balance
              : 0.0;
          quoteBalance = widget.balances.isNotEmpty
              ? widget.balances
                  .firstWhere(
                    (element) =>
                        element.currency.id ==
                        widget.selectedMarket.quoteUnit.id,
                  )
                  .balance
              : 0.0;
          amount = widget.amount == null ? null : widget.amount;
        },
      );
    } else {
      setState(() {
        price = widget.price == null
            ? widget.selectedMarket.ticker.last
            : widget.price;
        baseBalance = widget.balances.isNotEmpty
            ? widget.balances
                .firstWhere(
                  (element) =>
                      element.currency.id == widget.selectedMarket.baseUnit.id,
                )
                .balance
            : 0.0;
        quoteBalance = widget.balances.isNotEmpty
            ? widget.balances
                .firstWhere(
                  (element) =>
                      element.currency.id == widget.selectedMarket.quoteUnit.id,
                )
                .balance
            : 0.0;
        amount = widget.amount == null ? null : widget.amount;
        limitSelected = widget.limitSelected ?? true;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    sellSelected = false;
    price =
        widget.price == null ? widget.selectedMarket.ticker.last : widget.price;
    baseBalance = widget.balances.isNotEmpty
        ? widget.balances
            .firstWhere(
              (element) =>
                  element.currency.id == widget.selectedMarket.baseUnit.id,
            )
            .balance
        : 0.0;
    quoteBalance = widget.balances.isNotEmpty
        ? widget.balances
            .firstWhere(
              (element) =>
                  element.currency.id == widget.selectedMarket.quoteUnit.id,
            )
            .balance
        : 0.0;
    amount = widget.amount == null ? null : widget.amount;
    limitSelected = widget.limitSelected ?? true;
    priceController.text = limitSelected
        ? ''
        : price.toStringAsFixed(widget.selectedMarket.pricePrecision);
    amountController.text = amount == null ? '' : amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    var percentageButtonLables = [5, 25, 50, 100];
    side = sellSelected ? orderSide.sell : orderSide.buy;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: sellSelected ? 0 : 8,
                  child: Text(
                    tr('buy'),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  color: sellSelected
                      ? Theme.of(context).colorScheme.primary
                      : systemGreen,
                  onPressed: () {
                    setState(() {
                      sellSelected = false;
                      if (limitSelected) {
                        priceController.text = '';
                        amountController.text = '';
                      } else {
                        amountController.text = '';
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: sellSelected ? 8 : 0,
                  child: Text(
                    tr('sell'),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  color: sellSelected
                      ? systemRed
                      : Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    setState(() {
                      sellSelected = true;
                      if (limitSelected) {
                        priceController.text = '';
                        amountController.text = '';
                      } else {
                        amountController.text = '';
                      }
                    });
                  },
                ),
              )
            ],
          ),
        ),
        SpaceH4(),
        Align(
          alignment: Alignment.centerLeft,
          child: CustomSwitch(
            bgColor: widget.switchBgColor,
            selectedText: tr('limit_label'),
            defaultText: tr('market_label'),
            selected: limitSelected,
            onToggle: (selected) {
              setState(
                () {
                  limitSelected = selected;
                  if (!limitSelected) {
                    priceController.text = widget.selectedMarket.ticker.last
                        .toStringAsFixed(widget.selectedMarket.pricePrecision);
                    amountController.text = '';
                  } else {
                    priceController.text = '';
                    amountController.text = '';
                  }
                },
              );
            },
          ),
        ),
        SpaceH12(),
        TextFormField(
          inputFormatters: [
            !isDesktop(context)
                ? RegExInputFormatter.withRegex(
                    '^\$|^(0|([1-9][0-9]{0,}))([\\.|\\,][0-9]{0,})?\$')
                : RegExInputFormatter.withRegex(
                    '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$'),
            NumberTextInputFormatter(
              decimalRange: widget.selectedMarket.pricePrecision,
            ),
          ],
          controller: priceController,
          readOnly: !limitSelected,
          style: Theme.of(context).textTheme.bodyText2.copyWith(
                fontSize: 14.0,
              ),
          cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          onChanged: (str) {
            if (double.parse(str) != widget.selectedMarket.ticker.last) {
              setState(
                () {
                  limitSelected = true;
                },
              );
            }
          },
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: 14.0,
                ),
            prefixStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: 14.0,
                ),
            prefixText: !limitSelected ? '≈' : '',
            hintText: tr('price_label') +
                ' ' +
                (widget.selectedMarket == null
                    ? ''
                    : widget.selectedMarket.name.split('/')[1]),
          ),
        ),
        SpaceH12(),
        TextFormField(
          inputFormatters: [
            !isDesktop(context)
                ? RegExInputFormatter.withRegex(
                    '^\$|^(0|([1-9][0-9]{0,}))([\\.|\\,][0-9]{0,})?\$')
                : RegExInputFormatter.withRegex(
                    '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$'),
            NumberTextInputFormatter(
              decimalRange: widget.selectedMarket.amountPrecision,
            ),
          ],
          cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
          controller: amountController,
          style: Theme.of(context).textTheme.bodyText2.copyWith(
                fontSize: 14.0,
              ),
          onChanged: (str) {
            setState(() {});
          },
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: 14.0,
                ),
            prefixStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: 14.0,
                ),
            hintText: tr('amount_label') +
                ' ' +
                (widget.selectedMarket == null
                    ? ''
                    : widget.selectedMarket.name.split('/')[0]),
          ),
        ),
        SpaceH8(),
        Row(
          children: List.generate(
            percentageButtonLables.length,
            (index) => Expanded(
              child: exchangeTopButtonTheme(
                context,
                Padding(
                  padding: EdgeInsets.all(2.0),
                  child: MaterialButton(
                    visualDensity: VisualDensity.comfortable,
                    color: Theme.of(context).colorScheme.primaryVariant,
                    child: Text(
                      '${percentageButtonLables[index]}%',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 14,
                          ),
                    ),
                    elevation: 4,
                    onPressed: () {
                      if (side == orderSide.sell) {
                        amountController.text = toStringWithPrecision(
                          baseBalance / 100 * percentageButtonLables[index],
                          widget.selectedMarket.amountPrecision,
                        );
                        setState(
                          () {},
                        );
                      } else {
                        amountController.text = toStringWithPrecision(
                          (quoteBalance /
                              double.parse(
                                  priceController.text.replaceAll(',', '.')) /
                              100 *
                              percentageButtonLables[index]),
                          widget.selectedMarket.amountPrecision,
                        );
                        setState(
                          () {},
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        SpaceH8(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              "${tr('total_label')} ${tr('sum_label')}:",
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            Text(
              priceController.text == '' || amountController.text == ''
                  ? ''
                  : (!limitSelected ? '≈' : '') +
                      formatNumber(
                        double.parse(
                                priceController.text.replaceAll(',', '.')) *
                            double.parse(
                              amountController.text.replaceAll(',', '.'),
                            ),
                        widget.selectedMarket.pricePrecision,
                      ).toString(),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14.0,
                  ),
            ),
          ],
        ),
        SpaceH8(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              side == orderSide.buy
                  ? "${tr('available_label')} ${widget.selectedMarket.quoteUnit.id.toUpperCase()}: "
                  : "${tr('available_label')} ${widget.selectedMarket.baseUnit.id.toUpperCase()}: ",
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14.0,
                  ),
            ),
            Text(
              side == orderSide.buy
                  ? (widget.isAuthourized)
                      ? quoteBalance.toStringAsFixed(
                          widget.selectedMarket.pricePrecision,
                        )
                      : 0.toStringAsFixed(widget.selectedMarket.pricePrecision)
                  : (widget.isAuthourized)
                      ? baseBalance.toStringAsFixed(
                          widget.selectedMarket.amountPrecision,
                        )
                      : 0.toStringAsFixed(
                          widget.selectedMarket.amountPrecision),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        SpaceH8(),
        AccountButton(
          buttonColor: side == orderSide.buy ? Colors.green : Colors.red,
          onPressed: widget.userSession == UserSessionState.initialState()
              ? null
              : () {
                  widget.onPlaceOrder(
                    widget.userSession.barongSession,
                    widget.selectedMarket.id,
                    side,
                    limitSelected ? orderType.limit : orderType.market,
                    double.parse(
                      amountController.text.replaceAll(',', '.'),
                    ),
                    double.parse(
                      priceController.text.replaceAll(',', '.'),
                    ),
                  );

                  if (widget.popAfterOrder) {
                    Navigator.of(context).pop();
                  }
                },
          text: side == orderSide.buy
              ? "${tr('buy_button').toUpperCase()} ${widget.selectedMarket.baseUnit.id.toUpperCase()}"
              : "${tr('sell_button').toUpperCase()} ${widget.selectedMarket.baseUnit.id.toUpperCase()}",
        ),
      ],
    );
  }
}
