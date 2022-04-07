// import 'package:flutter/material.dart';
// import 'package:flutter_locales/flutter_locales.dart';

// abstract class NameFieldValidator {
//   static String validate(BuildContext context, String value) {
//     if (value.length < 2) return Locales.string(context, "validate1");
//     if (value.length > 32) return Locales.string(context, "validate2");
//     return null;
//   }
// }

// abstract class EmailFieldValidator {
//   static Pattern get _pattern =>
//       r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
//   static RegExp get _regex => RegExp(_pattern);
//   static String validate(BuildContext context, String value) {
//     if (!_regex.hasMatch(value)) return Locales.string(context, "validate3");
//     return null;
//   }
// }

// abstract class AddressFieldValidator {
//   static String validate(BuildContext context, String value) {
//     if (value.length > 60) return Locales.string(context, "validate4");
//     return null;
//   }
// }

// abstract class CityFieldValidator {
//   static String validate(BuildContext context, String value) {
//     if (value.length > 20) return Locales.string(context, "validate5");
//     return null;
//   }
// }

// abstract class PostalCodeValidator {
//   static Pattern get _pattern => r'[0-9][0-9][0-9][0-9]\-[0-9][0-9][0-9]';
//   static RegExp get _regex => RegExp(_pattern);
//   static String validate(BuildContext context, String value) {
//     if (!_regex.hasMatch(value)) return Locales.string(context, "validate6");
//     return null;
//   }
// }

// abstract class NifFieldValidator {
//   static String validate(BuildContext context, String value) {
//     if (value.length != 9) return Locales.string(context, "validate7");
//     return null;
//   }
// }

// abstract class PasswordFieldValidator {
//   static String validate(BuildContext context, String value) {
//     if (value.length < 6)
//       return Locales.string(context, "validate8");
//     else if (value.length > 20) return Locales.string(context, "validate9");
//     return null;
//   }

//   static String confirm(BuildContext context, String value, String password) {
//     if (value != password) return Locales.string(context, "validate10");
//     return null;
//   }
// }

// class DescriptionFieldValidator {
//   static String error;
//   static String validate(BuildContext context, String value) {
//     if (value.length > 250) return Locales.string(context, "validate1");
//     return error;
//   }
// }

// class TableFieldValidator {
//   static String error;
//   static String validate(BuildContext context, String value) {
//     Pattern pattern = "^[0-9]|[0-9][0-9]|[0-9][0-9][0-9]";
//     RegExp regex = new RegExp(pattern);
//     if (!regex.hasMatch(value) || value.length > 3)
//       return Locales.string(context, "validate18");
//     if (value.length == 0) return Locales.string(context, "validate22");
//     return error;
//   }
// }

// class CreditCardNumberValidator {
//   static String error;
//   static String validate(BuildContext context, String value) {
//     if (value.length >= 20 && value.length <= 24) return error;
//     return Locales.string(context, "validate14");
//   }
// }

// class CVVNumberValidator {
//   static String error;
//   static String validate(BuildContext context, String value) {
//     //validate CVV number, return message error
//     if (value.length < 3 || value.length > 5)
//       return Locales.string(context, "validate15");
//     return error;
//   }
// }

// class ExpiryDateValidator {
//   static String error;
//   static String validate(BuildContext context, String value) {
//     //validate expiry date number, return message error
//     Pattern pattern = r'^([1-9]|0[1-9]|1[012])[/][2-9][1-9]';
//     RegExp regex = RegExp(pattern);
//     if (!regex.hasMatch(value)) return Locales.string(context, "validate16");
//     return error;
//   }
// }

// class CardHolderValidator {
//   static String error;
//   static String validate(BuildContext context, String value) {
//     //validate expiry date number, return message error
//     if (value.length > 24) return Locales.string(context, "validate17");
//     return error;
//   }
// }

// class MandatoryNifFieldValidator {
//   static String error;
//   static String validate(BuildContext context, String value) {
//     if (value.length != 9 && value.length != 0)
//       return Locales.string(context, "validate18");
//     return error;
//   }
// }

// class MandatoryCellphoneFieldValidator {
//   static String error;
//   static String validate(BuildContext context, String value) {
//     if ((value.length < 9 || value.length > 14) && value.length != 0)
//       return Locales.string(context, "validate19");
//     else if (value.length == 0) return Locales.string(context, "validate20");
//     return error;
//   }
// }

// class CellphoneFieldValidator {
//   static String error;
//   static String validate(BuildContext context, String value) {
//     if ((value.length < 9 || value.length > 14) && value.length != 0)
//       return Locales.string(context, "validate21");
//     return error;
//   }
// }

// class TipFieldValidator {
//   static String error;
//   static String validate(BuildContext context, String value) {
//     //   Pattern pattern = r'^\d+(,\d{3})*(\.\d{1,2})?$';
//     // RegExp regex = RegExp(pattern);
//     if (value.length > 4) return Locales.string(context, "validate25");
//     // else if (!regex.hasMatch(value)) return 'Enter a valid Tip';
//     return error;
//   }
// }
