import 'package:expense_tracker/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final DateTime date;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  const MyListTile(
      {super.key,
      required this.title,
      required this.trailing,
        required this.date,
      required this.onEditPressed,
      required this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        SlidableAction(
          onPressed: onEditPressed,
          icon: Icons.settings,
        ),
        SlidableAction(
          onPressed: onDeletePressed,
          icon: Icons.delete,
          backgroundColor: Colors.red,
        )
      ]),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: const BoxDecoration(
            color: BackgroundColor1
          ),
          child: ListTile(

              title: Text(title,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
              subtitle: Text("${date.year}-${date.month}-${date.day}",style:const TextStyle(color: Colors.white70),)
              ,
              trailing: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(trailing,style: const TextStyle(color: Colors.white,fontSize: 16),),
                ),
              )),
        ),
      ),
    );
  }
}
