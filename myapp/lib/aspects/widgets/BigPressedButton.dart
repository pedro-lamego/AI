import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BigPressedButton extends StatefulWidget {
  final AsyncCallback onPressed;
  final Widget child;
  final Color color;
  BigPressedButton({@required this.onPressed, @required this.child, this.color});

  @override
  State<BigPressedButton> createState() => _BigPressedButtonState();
}

class _BigPressedButtonState extends State<BigPressedButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
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
          primary: widget.color ?? theme.primaryColor,
          padding: const EdgeInsets.all(8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 150),
        ),
      ),
    );
  }
}
