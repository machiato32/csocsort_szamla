import 'package:flutter/material.dart';
import 'payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'new_expense.dart';
import 'user_settings.dart';
import 'history.dart';
import 'balances.dart';
import 'package:provider/provider.dart';
import 'app_state_notifier.dart';
import 'shopping.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String themeName='';
  if(!preferences.containsKey('theme')){
    preferences.setString('theme', 'greenLightTheme');
    themeName='greenLightTheme';
  }else{
    themeName=preferences.getString('theme');
  }
  runApp(ChangeNotifierProvider<AppStateNotifier>(
      create: (context) => AppStateNotifier(), child: CsocsortApp(themeName: themeName,)));
}
  String currentUser='';


class CsocsortApp extends StatefulWidget {
  final String themeName;

  const CsocsortApp({@required this.themeName});

  @override
  State<StatefulWidget> createState() => _CsocsortAppState();
}

class _CsocsortAppState extends State<CsocsortApp>{
  bool first=true;
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(
      builder: (context, appState, child){
        if(first) {
          appState.updateThemeNoNotify(widget.themeName);
          first=false;
        }
        return MaterialApp(
          title: 'Csocsort',
          theme: appState.theme,
          home: MainPage(
            title: 'Csocsort Main Page',
          ),
//          onGenerateRoute: Router.generateRoute,
//          initialRoute: '/',
        );

      },
    );
  }

}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  SharedPreferences prefs;

  Future<SharedPreferences> getPrefs() async{
    return await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    getPrefs().then((_prefs){
      if(!_prefs.containsKey('name')){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
      }else{
        setState(() {
          currentUser=_prefs.get('name');
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Csocsort számla',
          style: TextStyle(letterSpacing: 0.25, fontSize: 24),
        ),

      ),
      drawer: Drawer(
        elevation: 16,
        child: ListView(
          padding: EdgeInsets.only(top:23),
          children: <Widget>[
            DrawerHeader(
              child: SizedBox(height: 10),

              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    image: AssetImage('assets/csocsort_logo.png'))

              )
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Szia '+currentUser+'!',
                style: Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).textTheme.body2.color,
              ),
              title: Text(
                'Beállítások',
                style: Theme.of(context).textTheme.body2,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.wb_sunny,
                color: Theme.of(context).textTheme.body2.color,
              ),
              title: Text(
                'Még sok dolog',
                style: Theme.of(context).textTheme.body2,
              ),
              onTap: () {
//                Navigator.push(context,
//                    MaterialPageRoute(builder: (context) => Print()));
              },
            ),

            Divider(),
            ListTile(
              leading: Icon(
                Icons.bug_report,
                color: Colors.red,
              ),
              title: Text(
                'Probléma jelentése',
                style: Theme.of(context).textTheme.body2.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {},
              enabled: false,
            )
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        child: Icon(Icons.add),
        overlayColor: (Theme.of(context).brightness==Brightness.dark)?Colors.black:Colors.white,
//        animatedIcon: AnimatedIcons.menu_close,
        curve: Curves.bounceIn,

        children: [
          SpeedDialChild(
            label: 'Bevásárlás',
            child: Icon(Icons.shopping_basket),
            onTap: (){
              if(currentUser!="") Navigator.push(context, MaterialPageRoute(builder: (context) => NewExpense(type: ExpenseType.newExpense,)));
            }
          ),
          SpeedDialChild(
            label: 'Fizetés',
            child: Icon(Icons.attach_money),
            onTap: (){
              if(currentUser!="") Navigator.push(context, MaterialPageRoute(builder: (context) => Payment()));
            }
          ),
          SpeedDialChild(
            label: 'Bevásárlólista',
            child: Icon(Icons.add_shopping_cart),
            onTap: (){
              if(currentUser!="") Navigator.push(context, MaterialPageRoute(builder: (context) => AddShoppingRoute()));
            }
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: (){
          return getPrefs().then((_money) {
            setState(() {

            });
          });
        },
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[


            Balances(),
            ShoppingList(),
            History()
          ],
        ),
      ),

    );
  }
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => MainPage());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}