//입고
class StockReceipts {
  final String saUserid; // 회원 pk
  final int stockReceiptsQuantityReceived; //입고수량 //
  final DateTime stockReceiptsReceipDate; // 입고날짜
  final String sproductCode; // 제품코드
  final String smanufacturerName; //제조사명

  /// 제조사명

  StockReceipts({
    required this.saUserid,
    required this.stockReceiptsQuantityReceived,
    required this.stockReceiptsReceipDate,
    required this.sproductCode,
    required this.smanufacturerName,
  });
  factory StockReceipts.fromMap(Map<String, dynamic> res) {
  return StockReceipts(
    saUserid: res['saUserid'],
    stockReceiptsQuantityReceived: res['stockReceiptsQuantityReceived'],
    stockReceiptsReceipDate: DateTime.parse(res['stockReceiptsReceipDate']),
    sproductCode: res['sproductCode'],
    smanufacturerName: res['smanufacturerName'],
  );
}

}

