
enum Status{completed,pending}

class TransactionHistory {
final String data;
final String description;
final String amount;
final Status status;
  TransactionHistory({
    required this.data,
    required this.description,
    required this.amount,
    required this.status,
  });

}
