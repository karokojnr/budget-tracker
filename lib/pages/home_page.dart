import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../model/transaction_item.dart';
import '../view_models/budget_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AddTransactionDialog(
                  itemToAdd: (transactionItem) {
                    final budgetViewModel =
                        Provider.of<BudgetViewModel>(context, listen: false);
                    budgetViewModel.addItem(transactionItem);
                  },
                );
              });
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: screenSize.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Consumer<BudgetViewModel>(
                      builder: (context, value, child) {
                    final balance = value.getBalance(); // <- new
                    final budget = value.getBudget(); // <- new
                    double percentage = balance / budget;
                    // Making sure percentage isnt negative and isnt bigger than 1
                    if (percentage < 0) {
                      percentage = 0;
                    }
                    if (percentage > 1) {
                      percentage = 1;
                    }
                    return CircularPercentIndicator(
                      radius: screenSize.width / 2,
                      lineWidth: 10.0, // how thick the line is
                      percent: percentage, // percent goes from 0 -> 1
                      backgroundColor: Colors.white,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "\$${balance.toString().split(".")[0]}", // <- updated
                            style: const TextStyle(
                                fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Balance",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            "Budget: \$$budget", // <- updated
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      progressColor: Theme.of(context).colorScheme.primary,
                    );
                  }),
                ),
                const SizedBox(
                  height: 35,
                ),
                const Text(
                  "Items",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Consumer<BudgetViewModel>(builder: (context, value, child) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: value.items.length,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return TransactionCard(
                          item: value.items[index],
                        );
                      });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionItem item;
  const TransactionCard({Key? key, required this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0, top: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              offset: const Offset(0, 25),
              blurRadius: 50,
            )
          ],
        ),
        padding: const EdgeInsets.all(15.0),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Text(
              item.itemTitle,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Text(
              (!item.isExpense ? "+ " : "- ") + item.amount.toString(),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(TransactionItem) itemToAdd;
  const AddTransactionDialog({required this.itemToAdd, Key? key})
      : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController itemTitleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool _isExpenseController = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.3,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const Text(
                "Add an expense",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: itemTitleController,
                decoration: const InputDecoration(hintText: "Name of expense"),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(hintText: "Amount in \$"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Is expense?"),
                  Switch.adaptive(
                      value: _isExpenseController,
                      onChanged: (b) {
                        setState(() {
                          _isExpenseController = b;
                        });
                      })
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  if (amountController.text.isNotEmpty &&
                      itemTitleController.text.isNotEmpty) {
                    widget.itemToAdd(TransactionItem(
                        amount: double.parse(amountController.text),
                        itemTitle: itemTitleController.text,
                        isExpense: _isExpenseController));
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
