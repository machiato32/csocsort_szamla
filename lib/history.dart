import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'main.dart';

class HistoryData {
  DateTime date;
  String fromUser;
  List<String> toUser;
  String type;
  int amount, transactionID;
  String note;

  HistoryData({this.date, this.fromUser, this.toUser, this.type, this.amount, this.transactionID, this.note});

  factory HistoryData.fromJson(Map<String,dynamic> json){
//    json['Amount']=-json['Amount'];
    return HistoryData(
      amount: json['Amount'],
      fromUser: json['From_User'],
      toUser: json['To_User'].split(','),
      date: DateTime.parse(json['Date']),
      note: json['Note'],
      type: json['Type'],
      transactionID: json['Transaction_Id']
    );
  }

}

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  Future<List<HistoryData>> history;
  
  Future<List<HistoryData>> getHistory() async{
    Map<String,dynamic> map ={
      'name':name
    };
    String encoded = jsonEncode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/history/', body: encoded);

    List<dynamic> decoded = jsonDecode(response.body)['history'];

    List<HistoryData> history = new List<HistoryData>();
    decoded.forEach((element){history.add(HistoryData.fromJson(element));});
    history = history.reversed.toList();
    return history;
  }

  void callback(){
    setState(() {
      history=getHistory();
    });
  }

  @override
  void initState() {
    super.initState();
    history = getHistory();
  }
  @override
  void didUpdateWidget(History oldWidget) {
    history = getHistory();
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(8,4,8,4),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface,
                  blurRadius: 10,
                  spreadRadius: 5,
                )
              ],
              borderRadius: BorderRadius.circular(2)
          ),
          child: Column(
            children: <Widget>[
              Text('Előzmények', style: Theme.of(context).textTheme.title,),
              SizedBox(height: 40,),
              Center(
                child: FutureBuilder(
                  future: history,
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 400),
                        child: ListView(
                          shrinkWrap: true,
                          children: generateHistory(snapshot.data)
//                          HistoryElement(data: snapshot.data[index], callback: this.callback,);
                        ),
                      );
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }
  List<Widget> generateHistory(List<HistoryData> data){
    Function callback=this.callback;
    return data.map((element){return HistoryElement(data: element, callback: callback,);}).toList();
  }

}

class HistoryElement extends StatefulWidget {
  final HistoryData data;
  final Function callback;
  const HistoryElement({this.data, this.callback});
  @override
  _HistoryElementState createState() => _HistoryElementState();
}

class _HistoryElementState extends State<HistoryElement> {
  Color dateColor;
  Icon icon;
  TextStyle style;
  BoxDecoration boxDecoration;
  String date;
  String note;
  String names;
  String amount;
  int type;

  Future<bool> _deleteElement(int id) async {
    Map<String, dynamic> map = {
      "type":'delete',
      "Transaction_Id":id
    };

    String encoded = json.encode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/', body: encoded);

    widget.callback();

    return response.statusCode==200;
  }

  @override
  Widget build(BuildContext context) {
    date = DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.date);
    note = (widget.data.note=='')?'(nincs megjegyzés)':widget.data.note;
    if(widget.data.type=='add_expense'){
      type=0;
      icon=Icon(Icons.shopping_cart, color: Theme.of(context).textTheme.button.color);
      style=Theme.of(context).textTheme.button;
      dateColor=Theme.of(context).textTheme.button.color;
      boxDecoration=BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(4),
      );
      if(widget.data.toUser.length>1 && widget.data.toUser[1]!=''){
        names = widget.data.toUser[0]+' és még ${widget.data.toUser.length-1}';
      }else{
        names=widget.data.toUser[0];
      }
      amount = widget.data.amount.toString();
    }else if(widget.data.type=='new_expense'){
      type=1;
      icon=Icon(Icons.shopping_basket, color: Theme.of(context).textTheme.body2.color);
      style=Theme.of(context).textTheme.body2;
      dateColor=Theme.of(context).colorScheme.surface;
      names = widget.data.fromUser;
      amount = (-widget.data.amount).toString();
      boxDecoration=BoxDecoration();
    }else if(widget.data.fromUser==name){
      type=2;
      icon=Icon(Icons.call_made, color: Theme.of(context).textTheme.button.color);
      style=Theme.of(context).textTheme.button;
      dateColor=Theme.of(context).textTheme.button.color;
      boxDecoration=BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(4),
      );
      names = widget.data.toUser[0];
      amount = widget.data.amount.toString();
    }else{
      type=3;
      icon=Icon(Icons.call_received, color: Theme.of(context).textTheme.body2.color);
      style=Theme.of(context).textTheme.body2;
      dateColor=Theme.of(context).colorScheme.surface;
      names = widget.data.fromUser;
      amount = (-widget.data.amount).toString();
      boxDecoration=BoxDecoration();
    }
    if(type==0 || type==2){
      return Container(
        decoration: boxDecoration,
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    icon,
                    Text(' - '+names, style: style),
                    Text(': '+amount, style: style)
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(width: 20,),
                    Text(date, style: TextStyle(color: dateColor, fontSize: 15),)
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(width: 20,),
                    Text(note, style: TextStyle(color: dateColor, fontSize: 15),)
                  ],
                ),
                SizedBox(height: 4,)
              ],
            ),
            Container(
              child: FlatButton(
                onPressed: (){
                  showDialog(
                    context: context,
                    child: Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      backgroundColor: Theme.of(context).colorScheme.onBackground,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Törölni szeretnéd a tételt?', style: Theme.of(context).textTheme.title,),
                            SizedBox(height: 15,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                RaisedButton(
                                  color: Theme.of(context).colorScheme.secondary,
                                  onPressed: (){
                                    _deleteElement(widget.data.transactionID);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Igen', style: Theme.of(context).textTheme.button)
                                ),
                                RaisedButton(
                                    color: Theme.of(context).colorScheme.secondary,
                                    onPressed: (){ Navigator.pop(context);},
                                    child: Text('Nem', style: Theme.of(context).textTheme.button)
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  );
                },
                child: Icon(Icons.cancel, color: Theme.of(context).textTheme.button.color)
              )
            )
          ],
        ),
      );
    }
    return Container(
      decoration: boxDecoration,
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              icon,
              Text(' - '+names, style: style),
              Text(': '+amount, style: style)
            ],
          ),
          Row(
            children: <Widget>[
              SizedBox(width: 20,),
              Text(date, style: TextStyle(color: dateColor, fontSize: 15),)
            ],
          ),
          Row(
            children: <Widget>[
              SizedBox(width: 20,),
              Text(note, style: TextStyle(color: dateColor, fontSize: 15),)
            ],
          ),
          SizedBox(height: 4,)
        ],
      ),
    );
  }
}
