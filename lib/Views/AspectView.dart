import 'package:controle_qualite/Models/aspect.dart';
import 'package:controle_qualite/Screens/ControleFabrication.dart';
import 'package:flutter/material.dart';

class AspectView extends StatefulWidget {
  Aspect aspect;
  int index;
  bool isLast;
  FocusNode focusNode;
  FocusNode nextFocusNode;
  Color labelColor;
  var textFieldController = new TextEditingController();
  double val = 2;
  bool isYesNoQuestion = false;
  AspectView({
    this.aspect,
    this.focusNode,
    this.nextFocusNode,
    this.labelColor = Colors.black,
    this.isLast,
  }) {
    isYesNoQuestion = (aspect.qfControleValeurNominale == 1 &&
        aspect.qfControleToleranceN == 0 &&
        aspect.qfControleToleranceP == 0);
  }

  void setNewLabelColor(String value) {
    if (value == "") {
      this.labelColor = Colors.black;
    } else {
      double valueAsDouble = double.parse(value);
      if (valueAsDouble <
              aspect.qfControleValeurNominale - aspect.qfControleToleranceN ||
          valueAsDouble >
              aspect.qfControleValeurNominale + aspect.qfControleToleranceP)
        this.labelColor = Colors.red;
      else
        this.labelColor = Colors.green;
    }
  }

  double get value {
    return isYesNoQuestion ? val : double.tryParse(textFieldController.text);
  }

  bool get isEmpty {
    return (textFieldController.text == '' && !isYesNoQuestion) ||
        (val == 2 && isYesNoQuestion);
  }

  @override
  _AspectViewState createState() => _AspectViewState();
}

class _AspectViewState extends State<AspectView> {
  String dropDownValue = "Ignorer";
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          InkWell(
            onTap: () => widget.focusNode.requestFocus(),
            onLongPress: () => widget.focusNode.requestFocus(),
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: !widget.isYesNoQuestion
                ? Card(
                    shadowColor: widget.labelColor,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.aspect.qfControleTitre,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.labelColor,
                            ),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Valeur",
                              hintStyle: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[500],
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            textInputAction: widget.isLast
                                ? TextInputAction.done
                                : TextInputAction.next,
                            keyboardType: new TextInputType.numberWithOptions(
                              signed: false,
                              decimal: true,
                            ),
                            controller: widget.textFieldController,
                            focusNode: widget.focusNode,
                            onFieldSubmitted: (term) =>
                                ControlePage.goToNextField(
                              current: widget.focusNode,
                              next: widget.nextFocusNode,
                              isLast: widget.isLast,
                            ),
                            onChanged: (value) {
                              widget.setNewLabelColor(value);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : Card(
                    shadowColor: widget.labelColor,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                        right: 10,
                        left: 10,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.aspect.qfControleTitre,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: widget.labelColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: 6,
                                right: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2.0,
                                  color: widget.labelColor.withOpacity(0.65),
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    10,
                                  ),
                                ),
                              ),
                              child: DropdownButton<String>(
                                focusNode: widget.focusNode,
                                underline: Container(),
                                value: dropDownValue,
                                icon: Icon(
                                  Icons.arrow_downward,
                                  color: widget.labelColor,
                                ),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                onChanged: (String newValue) {
                                  dropDownValue = newValue;
                                  switch (dropDownValue) {
                                    case 'Conforme':
                                      widget.val = 1;
                                      widget.labelColor = Colors.green;
                                      break;
                                    case 'Non Conforme':
                                      widget.val = 0;
                                      widget.labelColor = Colors.red;
                                      break;
                                    default:
                                      widget.labelColor = Colors.black;
                                  }
                                  widget.focusNode.requestFocus();
                                  setState(() {});
                                },
                                items: <String>[
                                  'Conforme',
                                  'Non Conforme',
                                  'Ignorer'
                                ].map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
