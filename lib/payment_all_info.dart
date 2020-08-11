import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'payment_entry.dart';

class PaymentAllInfo extends StatefulWidget {

  final PaymentData data;
  PaymentAllInfo(this.data);
  @override
  _PaymentAllInfoState createState() => _PaymentAllInfoState();
}

class _PaymentAllInfoState extends State<PaymentAllInfo> {

  Future<bool> _deleteElement(int id) async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.delete(APPURL+'/payments/'+id.toString(), headers: header);
      return response.statusCode==204;
    }catch(_){
      throw _;
    }
  }
  @override
  Widget build(BuildContext context) {
    String note='';
    if(widget.data.note=='' || widget.data.note==null){
      note='Nincs megjegyzés';
    }else{
      note=widget.data.note[0].toUpperCase()+widget.data.note.substring(1);
    }
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.note, color: Theme.of(context).colorScheme.primary),
                  Text(' - '),
                  Flexible(child: Text(note, style: Theme.of(context).textTheme.bodyText1,)),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: <Widget>[
                  Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary),
                  Text(' - '),
                  Flexible(child: Text(widget.data.payerNickname, style: Theme.of(context).textTheme.bodyText1,)),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.account_box, color: Theme.of(context).colorScheme.primary),
                  Text(' - '),
                  Flexible(child: Text(widget.data.takerNickname, style: Theme.of(context).textTheme.bodyText1, )),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: <Widget>[
                  Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary),
                  Text(' - '),
                  Flexible(child: Text(widget.data.amount.toString(), style: Theme.of(context).textTheme.bodyText1)),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: <Widget>[
                  Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary,),
                  Text(' - '),
                  Flexible(child: Text(DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.updatedAt), style: Theme.of(context).textTheme.bodyText1)),
                ],
              ),
              SizedBox(height: 10,),
              Visibility(
                visible: widget.data.payerId==currentUser,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
//                          FlatButton.icon(
//
//                            onPressed: (){
//                              showDialog(
//                                  context: context,
//                                  child: Dialog(
//                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                                    backgroundColor: Theme.of(context).colorScheme.onBackground,
//                                    child: Container(
//                                      padding: EdgeInsets.all(8),
//                                      child: Column(
//                                        crossAxisAlignment: CrossAxisAlignment.center,
//                                        mainAxisSize: MainAxisSize.min,
//                                        children: <Widget>[
//                                          Text('Szerkeszteni szeretnéd a tételt?', style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
//                                          SizedBox(height: 15,),
//                                          Row(
//                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                            children: <Widget>[
//                                              RaisedButton(
//                                                  color: Theme.of(context).colorScheme.secondary,
//                                                  onPressed: (){
//                                                        Navigator.pop(context);
//                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewExpense(type: ExpenseType.fromSavedExpense,
//                                                          expense: new SavedExpense(name: widget.data.fromUser,
//                                                              names: widget.data.toUser,
//                                                              amount: widget.data.amount,
//                                                              note: widget.data.note,
//                                                              iD: widget.data.transactionID
//                                                          ),
//                                                        )));
//                                                  },
//                                                  child: Text('Igen', style: Theme.of(context).textTheme.button)
//                                              ),
//                                              RaisedButton(
//                                                  color: Theme.of(context).colorScheme.secondary,
//                                                  onPressed: (){ Navigator.pop(context);},
//                                                  child: Text('Nem', style: Theme.of(context).textTheme.button)
//                                              )
//                                            ],
//                                          )
//                                        ],
//                                      ),
//                                    ),
//                                  )
//                              );
//                            },
//                            color: Theme.of(context).colorScheme.secondary,
//                            label: Text('Szerkesztés', style: Theme.of(context).textTheme.button,),
//                            icon: Icon(Icons.edit, color: Theme.of(context).textTheme.button.color),
//                          ),
                    FlatButton.icon(
                        onPressed: (){
                          showDialog(
                              context: context,
                              child: Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[//TODO: edit here and transaction
                                      Text('Törölni szeretnéd a tételt?', style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),),
                                      SizedBox(height: 15,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          RaisedButton(
                                              color: Theme.of(context).colorScheme.secondary,
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                Future<bool> success = _deleteElement(widget.data.paymentId);
                                                showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    child: Dialog(
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                      backgroundColor: Colors.transparent,
                                                      elevation: 0,
                                                      child: FutureBuilder(
                                                        future: success,
                                                        builder: (context, snapshot){
                                                          if(snapshot.connectionState==ConnectionState.done){
                                                            if(snapshot.hasData && snapshot.data){
                                                              return Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Flexible(child: Text("A tranzakciót sikeresen töröltük!", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                                                                  SizedBox(height: 15,),
                                                                  FlatButton.icon(
                                                                    icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                                                    onPressed: (){
                                                                      Navigator.pop(context);
                                                                      Navigator.pop(context, 'deleted');
                                                                    },
                                                                    label: Text('Rendben', style: Theme.of(context).textTheme.button,),
                                                                    color: Theme.of(context).colorScheme.secondary,
                                                                  )
                                                                ],
                                                              );
                                                            }else{
                                                              return Container(
                                                                color: Colors.transparent ,
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Flexible(child: Text("Hiba történt!", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                                                                    SizedBox(height: 15,),
                                                                    FlatButton.icon(
                                                                      icon: Icon(Icons.clear, color: Colors.white,),
                                                                      onPressed: (){
                                                                        Navigator.pop(context);
                                                                      },
                                                                      label: Text('Vissza', style: Theme.of(context).textTheme.button.copyWith(color: Colors.white)),
                                                                      color: Colors.red,
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                          }
                                                          return Center(child: CircularProgressIndicator());

                                                        },
                                                      ),
                                                    )
                                                );
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
                        color: Theme.of(context).colorScheme.secondary,
                        label: Text('Törlés', style: Theme.of(context).textTheme.button,),
                        icon: Icon(Icons.cancel, color: Theme.of(context).textTheme.button.color)
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}
