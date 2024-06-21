import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier{ 
  static late Isar isar;

  List<Expense> _allExpense = [];

  /* 

  SETUP

  */ 

  //initilaze db 
  static Future<void> initialize() async{

    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  } 
 /* 

  Getters

  */ 

  List<Expense> get allExpense => _allExpense;
  /* 

 Operations

  */ 

  //Create 
  Future<void> CreateNewExpense(Expense newExpense) async {

    //add to db  
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    await ReadExpense();
  }

  //Read
  Future<void> ReadExpense() async {

    List<Expense> fetchedExpense = await isar.expenses.where().findAll();

    _allExpense.clear();
    _allExpense.addAll(fetchedExpense);

    notifyListeners();
  }

  //update 

  Future<void> updateExpene(int id , Expense updateExpens) async {

    updateExpens.id = id; 

    await isar.writeTxn(() => isar.expenses.put(updateExpens)) ;

    await ReadExpense();
  }
  //Delete

  Future<void> deleteExpense(int id) async { 
    await isar.writeTxn(() => isar.expenses.delete(id)); 
    await ReadExpense();
  }


  //calculate total expenses for each monthy

  Future<Map<int,double>> calculateMonthlyTotals() async {
    await ReadExpense(); 
    
    //create a map to keep track of total expenses per month
    Map<int, double> monthlyTotals = {}; 

    //iterate over all expenses 
    for(var expense in _allExpense) {
      //extract the month from the date of the expense 
      int month = expense.date.month;

      //if the month is not yet in the map initialize to 0 

      if(!monthlyTotals.containsKey((month))){
        monthlyTotals[month] = 0 ;
      }

      //add the expense amount to the total for the month 
      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }
    return monthlyTotals;
  }

  //get start month 

  int getStartMonth() { 
    if(_allExpense.isEmpty) {
      return DateTime.now().month; //default to current moth is no expenses are recorded
    }

    //sort expenses by date to find the earLiest
    _allExpense.sort((a, b) => a.date.compareTo(b.date));

    return _allExpense.first.date.month;
  }

  int getStartYear() { 
     if(_allExpense.isEmpty) {
      return DateTime.now().year; //default to current moth is no expenses are recorded
    }

    //sort expenses by date to find the earLiest
    _allExpense.sort((a, b) => a.date.compareTo(b.date));
    return _allExpense.first.date.year;
  }

  //calculate current month total 

  Future<double> calculateCurrentMonthTotal() async{ 

    await ReadExpense(); 

    int currentMonth = DateTime.now().month; 
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpenses = _allExpense.where((e){ 
      return e.date.month == currentMonth && 
      e.date.year == currentYear;
    } ).toList();

    double total = currentMonthExpenses.fold(0, (sum, e) => sum + e.amount);

    return total;
  
  }

  
} 