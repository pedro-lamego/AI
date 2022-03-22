import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PressedButton extends StatefulWidget {
  final AsyncCallback onPressed;
  final Widget child;
  PressedButton({@required this.onPressed, @required this.child});

  @override
  State<PressedButton> createState() => _PressedButtonState();
}

class _PressedButtonState extends State<PressedButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: widget.onPressed == null
          ? null
          : () async {
              if (isLoading) return;
              setState(() => isLoading = true);
              await widget.onPressed();
              setState(() => isLoading = false);
            },
      child: isLoading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                color: theme.colorScheme.onPrimary,
                strokeWidth: 2,
              ),
            )
          : widget.child,
      style: ElevatedButton.styleFrom(
        primary: theme.primaryColor,
        padding: const EdgeInsets.all(8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
      ),
    );
  }
}
