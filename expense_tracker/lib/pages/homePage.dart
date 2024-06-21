import 'package:expense_tracker/bar_graph/bar_graphh.dart';
import 'package:expense_tracker/components/My_List_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helpers/helperfunction.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/style/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amoungController = TextEditingController();

  //future to load graph data & monthly total
  Future<Map<int, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  //refresh graph data

  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();

    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).ReadExpense();
    refreshData();
    super.initState();
  }

  void newExpenseBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Yeni Harcama"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: ("Name")),
                  ),
                  TextField(
                    controller: amoungController,
                    decoration: const InputDecoration(hintText: ("Amount")),
                  )
                ],
              ),
              actions: [canselButton(), saveButton()],
            ));
  }

  void OpenEditBox(Expense expense) {
    String editNanme = expense.name;
    String editAmount = expense.amount.toString();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Yeni Harcama"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: (editNanme)),
                  ),
                  TextField(
                    controller: amoungController,
                    decoration: InputDecoration(hintText: (editAmount)),
                  )
                ],
              ),
              actions: [canselButton(), editButton(expense)],
            ));
  }

  void OpenDeleteBox(Expense expense) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Silmek İstiyormusun"),
              actions: [canselButton(), deleteButton(expense.id)],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      //get dates

      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;
      //calculate the number of months since the first month
      int monthCount =
          calculateMonthCount(startYear, startMonth, currentYear, currentMonth);
      // only display the expenses for the current month
      List<Expense> currentMonthExprense = value.allExpense.where((expense) {
        return expense.date.year == currentYear &&
            expense.date.month == currentMonth;
      }).toList();

      //return UI
      return Scaffold(
          backgroundColor: BackgroundColor1,
          floatingActionButton: FloatingActionButton(
            onPressed: newExpenseBox,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: FutureBuilder<double>(
                future: _calculateCurrentMonthTotal,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("₺" + snapshot.data!.toStringAsFixed(2),style: TextStyle(color: Colors.white),),
                        Text(getCurrentMonthName(),style: TextStyle(color: Colors.white),)
                      ],
                    );
                  } else {
                    return Text("Yükleniyor");
                  }
                }),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: FutureBuilder(
                        future: _monthlyTotalsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            final monthlyTotals = snapshot.data ?? {};

                            //create the list of month sumary

                            List<double> monthlySummary = List.generate(
                                monthCount,
                                (index) =>
                                    monthlyTotals[startMonth + index] ?? 00);
                            return MyBarGraph(
                                monthlySummary: monthlySummary,
                                starMonth: startMonth);
                          } else {
                            return const Center(
                              child: Text("Yükleniyor"),
                            );
                          }
                        }),
                  ),
                  Expanded(
                    child: Container(
                      color: Color(0xff23203F),
                      child: ListView.builder(
                        itemCount: currentMonthExprense.length,
                        itemBuilder: (context, index) {
                          int reversedIndex =
                              currentMonthExprense.length - 1 - index;
                          Expense individualExpense =
                              currentMonthExprense[reversedIndex];
                          return MyListTile(
                              title: individualExpense.name,
                              trailing: formatAmount(individualExpense.amount),
                              date: individualExpense.date,
                              onEditPressed: (context) =>
                                  OpenEditBox(individualExpense),
                              onDeletePressed: (context) =>
                                  OpenDeleteBox(individualExpense));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
    });
  }

  Widget canselButton() {
    return MaterialButton(
      onPressed: () {
        nameController.clear();
        amoungController.clear();
        Navigator.pop(context);
      },
      child: Text("Geri"),
    );
  }

  Widget saveButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amoungController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense newExpense = Expense(
              name: nameController.text,
              amount: stringconvertToDouble(amoungController.text),
              date: DateTime.now());

          //save to db
          await context.read<ExpenseDatabase>().CreateNewExpense(newExpense);
          refreshData();
          nameController.clear();
          amoungController.clear();
        }
      },
      child: Text("Kayıt Et"),
    );
  }

  Widget editButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amoungController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense updateExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amoungController.text.isNotEmpty
                  ? stringconvertToDouble(amoungController.text)
                  : expense.amount,
              date: DateTime.now());

          int existingId = expense.id;

          await context
              .read<ExpenseDatabase>()
              .updateExpene(existingId, updateExpense);
        }
        refreshData();
      },
      child: Text("Güncelle"),
    );
  }

  Widget deleteButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);

        await context.read<ExpenseDatabase>().deleteExpense(id);
        refreshData();
      },
      child: Text("Sil"),
    );
  }
}
