import 'package:isar/isar.dart';


//this line is needed to generate  isar file
// run cmd is terminal : dart run build_runner build
part 'expense.g.dart';

@Collection()
class Expense{
  Id id = Isar.autoIncrement; 

 final String name;
 final double amount; //fiyat 
 final DateTime date; 


 Expense({required this.name,required this.amount , required this.date});

}