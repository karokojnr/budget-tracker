class TransactionItem {
  TransactionItem(
      {required this.amount, required this.itemTitle, this.isExpense = true});
  String itemTitle;
  double amount;
  bool isExpense;
}
