import 'package:flutter/material.dart';
import 'package:no_to_do/model/nodo_item.dart';
import 'package:no_to_do/util/database_client.dart';
import 'package:no_to_do/util/date.dart';

class NoToDoScreen extends StatefulWidget {
  @override
  _NoToDoScreenState createState() => _NoToDoScreenState();
}

class _NoToDoScreenState extends State<NoToDoScreen> {

  final TextEditingController _textEditingController = new TextEditingController();
  var db = new DatabaseHelper();
  final List<NoDoItem> _itemList = <NoDoItem>[];

  @override
  void initState() {
    super.initState();
    _readNoDoList();
  }



  void _handleSubmit(String text) async {
_textEditingController.clear();
NoDoItem noDoItem = new NoDoItem(text,dateFormatted());
int saveItemId = await db.saveItem(noDoItem);
NoDoItem addedItem = await db.getItem(saveItemId);

setState(() {
  _itemList.insert(0,addedItem);

});
print("Item saved item: $saveItemId");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                  padding : new EdgeInsets.all(8.0),
                  itemCount: _itemList.length,
                  itemBuilder: (_,int index){
                        return new Card (
                          color: Colors.white10,
                          child: new ListTile(
                            title: _itemList[index],
                            onLongPress: () => _updateItem(_itemList[index],index),
                            trailing: new Listener(
                              key: new Key(_itemList[index].itemName),
                              child: new Icon(Icons.remove_circle,color: Colors.redAccent,),
                              onPointerDown: (pointerEvent) =>
                              _deleteNoDo(_itemList[index].id,index),

                            ),
                          ),
                        );
                  }
              ),
          ),
          new Divider(
            height: 1.0,
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          onPressed: _showFormDialog,
          tooltip: "Add Item",
          backgroundColor: Colors.redAccent,
          child: new ListTile(
            title: new Icon(Icons.add),
          ),
      ),
    );
  }

  void _showFormDialog() {
    var alert = new AlertDialog(
      content:  new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: "Item",
                  hintText: "eg. Dont buy stuff",
                  icon: new Icon(Icons.note_add)
                ),
              )
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: (){
              _handleSubmit(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: new Text("Save"),
        ),
        new FlatButton(
            onPressed: ()=> Navigator.pop(context),
            child: new Text("Cancel"),
        )
      ],
    );
    showDialog(context: context,builder: (_) => alert);
  }

  _readNoDoList() async {
    List items = await db.getItems();
    items.forEach((items){
      //NoDoItem noDoItem = NoDoItem.map(items);
      setState(() {
        _itemList.add(NoDoItem.map(items));
      });
      //print("Db items: ${noDoItem.itemName}");
    });
  }

  _deleteNoDo(int id,int index) async {
      debugPrint("Deleted item");
      await db.deleteItem(id);
      setState(() {
        _itemList.removeAt(index);
      });
  }

  _updateItem(NoDoItem itemList, int index) {
    var alert = new AlertDialog(
      title: new Text("Update Item"),
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: "Item",
                  hintText: "eg.Dont buy stuff",
                  icon: new Icon(Icons.update),
                ),
              ),
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () async {
              NoDoItem newItemUpdated  = NoDoItem.fromMap(
                {"itemName":_textEditingController.text,
                  "dateCreated":dateFormatted(),
                  "id":itemList.id
                }
              );
              _handleSubmittedUpdate(index,itemList); //redrawing the screen
              await db.updateItem(newItemUpdated); //updating the item
              setState(() {
                _readNoDoList(); //redrawing the screen with all items in database
              });
              Navigator.pop(context);
            },
            child: new Text("Update"),
        ),
        new FlatButton(
            onPressed:()=> Navigator.pop(context),
            child: new Text("Cancel"),
        ),
      ],
    );
    showDialog(context: context,builder: (_) => alert);
  }

  void _handleSubmittedUpdate(int index, NoDoItem itemList) {
    setState(() {
          _itemList.removeWhere((element){
            _itemList[index].itemName == itemList.itemName;
          });
    });
  }

}
