import 'package:flutter/material.dart';

class StandardInput extends StatefulWidget {
  String hintText;
  String initialValue;
  Function save;

  StandardInput({this.hintText, this.initialValue, this.save});

  @override
  _StandardInputState createState() => _StandardInputState();
}

class _StandardInputState extends State<StandardInput> {
  var textEditingController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    textEditingController = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).hintColor,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  autofocus: true,
                  controller: textEditingController,
                  decoration: InputDecoration(hintText: widget.hintText),
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return '内容不能为空';
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    child: Text('取消'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text('保存'),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Navigator.pop(context);
                        widget.save(textEditingController.text);
                      }
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
