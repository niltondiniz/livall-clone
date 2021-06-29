import 'package:flutter/material.dart';

class BotaoPositioned extends StatelessWidget {
  final EdgeInsets pad;
  final AlignmentGeometry alinhamento;
  final double height;
  final double width;
  final Color color;
  final Widget icone;
  final Function evento;

  const BotaoPositioned(this.pad, this.alinhamento, this.height, this.width,
      this.color, this.icone, this.evento);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: Padding(
        padding: pad,
        child: Align(
          alignment: alinhamento,
          child: Container(
            child: GestureDetector(
              onTap: evento,
              child: ClipOval(
                child: Container(
                  height: height, // height of the button
                  width: width, // width of the button
                  color: color,
                  child: icone,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BotaoContato extends StatelessWidget {
  final Widget icone;
  final Color color;

  const BotaoContato(this.icone, this.color);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        height: 40, // height of the button
        width: 40, // width of the button
        color: color,
        child: icone,
      ),
    );
  }
}

class IconPtt extends StatelessWidget {
  final IconData icone;
  final double size;
  final Color color;

  const IconPtt(this.icone, this.size, this.color);

  @override
  Widget build(BuildContext context) {
    return Icon(
      this.icone,
      size: this.size,
      color: this.color,
    );
  }
}
