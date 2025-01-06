import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';

const double endValue = 4.0;
const double startValue = 0.0;

class CustomNeuButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color buttonColor;
  final Color textColor;

  const CustomNeuButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.buttonColor = Colors.yellow,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  _CustomNeuButtonState createState() => _CustomNeuButtonState();
}

class _CustomNeuButtonState extends State<CustomNeuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Animation pour l'effet de rétraction de l'ombre et du bouton
    _pressAnimation = Tween<double>(
      begin: 0.0, // Rétracté (0.0)
      end: 4.0, // Normal (déployé à 4.0)
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController
        .forward(); // Démarre l'animation de rétraction de l'ombre
  }

  void _onTapUp(TapUpDetails details) {
    _animationController
        .reverse(); // L'ombre revient à son état normal (déployée)
    widget.onPressed();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final shadowOffset = endValue -
            _pressAnimation.value; // Ajuste l'ombre en fonction de l'animation
        final buttonOffset = _pressAnimation
            .value; // Déplace le bouton en fonction de l'animation

        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Stack(
            children: [
              // Ombre (déployée par défaut, rétractée lors de l'appui)
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(shadowOffset,
                      shadowOffset), // L'ombre se rétracte complètement
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // Bouton principal
              Transform.translate(
                offset: Offset(buttonOffset,
                    buttonOffset), // Déplace également le bouton lors du clic
                child: Container(
                  height: 60,
                  width: 200,
                  decoration: BoxDecoration(
                    color: widget.buttonColor,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(shadowOffset,
                            shadowOffset), // Ombre nette sans flou
                        blurRadius: 0, // Pas de flou
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: widget.textColor),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NeuTitle extends StatelessWidget {
  final String text;
  final double fontSize;

  const NeuTitle({
    Key? key,
    required this.text,
    this.fontSize = 32,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0, // Pas de flou
          ),
        ],
      ),
      child: Text(text, style: AppTextStyles.titleBlackStyle),
    );
  }
}
