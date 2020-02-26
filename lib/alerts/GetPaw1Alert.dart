import 'package:flutter/material.dart';

class GetPaw1Alert extends StatefulWidget {
  GetPaw1Alert({
    Key key,
    @required this.onJDEvent,
    @required this.onTmallEvent,
    @required this.onCloseEvent,
  }) : super(key: key);

  //去京东
  Function onJDEvent;
  //去天猫
  Function onTmallEvent;
  //关闭 界面
  Function onCloseEvent;
  
  @override
  _GetPaw1AlertState createState() => _GetPaw1AlertState();
}

class _GetPaw1AlertState extends State<GetPaw1Alert> {
  @override
  Widget build(BuildContext context) {

    return Material(
      type: MaterialType.transparency,
      child:InkWell(
        child: Center(
          child: Container(
            height: 250,
            width: 340,
            decoration: ShapeDecoration(
              color: Color(0xff212124),//可以自定义一个颜色传过来
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              )
            ),
            alignment: Alignment.topCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child:Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: getDecorationWidget(context),
                  ),
                  Padding(padding: EdgeInsets.only(top: 42)),
                  titleText(context),
                  Padding(padding: EdgeInsets.only(top: 51)),
                  Container(
                    width: 291,
                    height: 44,
                    decoration: ShapeDecoration(
                      color: Color(0xff323237),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        JDButton(context),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          indent: 7,
                          endIndent: 7,
                          color: Color(0xFF494A4D),
                        ),
                        tmallButton(context)
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 22)),
                ],
              )
            ) 
          ),
        ),
        onTap: widget.onCloseEvent,
        onLongPress: widget.onCloseEvent,
      )
    );
  }

  //widgets ----------------

  List<Widget> getDecorationWidget (BuildContext context) {
    List<Widget> widgets = List();
    for (var i = 0; i < 7; i++) {
      Widget tempWidget = Container(
        width: 48,
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(23.0),bottomRight: Radius.circular(23.0)),
          color: i%2 == 0 ? Color(0xFF4C2A2E):Color(0xFF4A4B4E),
        ),
      );
      widgets.add(tempWidget);
    }
    return widgets;
  }

  Widget titleText (BuildContext context) {
    return Text(
      "前去官方旗舰店进行购买",
      style: TextStyle(
          fontFamily: "PuHuiTi",
          fontWeight: FontWeight.w500,
          color: Color(0xFFF6F7FB),
          fontSize: 18.0,
          wordSpacing: 1,
          height: 25.0 / 18.0
      ),
    );
  }

  Widget JDButton (BuildContext context) {
    return FlatButton(
      onPressed: widget.onJDEvent,
      child: Text(
        "京东旗舰店",
        style: TextStyle(
            fontFamily: "PuHuiTi",
            fontWeight: FontWeight.w500,
            color: Color(0xFFF6F7FB),
            fontSize: 18.0,
            wordSpacing: 1,
            height: 25.0 / 18.0
        ),
      ),
    );
  }

  Widget tmallButton (BuildContext context) {
    return FlatButton(
      onPressed: widget.onTmallEvent,
      child: Text(
        "天猫旗舰店",
        style: TextStyle(
            fontFamily: "PuHuiTi",
            fontWeight: FontWeight.w500,
            color: Color(0xFFF6F7FB),
            fontSize: 18.0,
            wordSpacing: 1,
            height: 25.0 / 18.0
        ),
      ),
    );
  }

}