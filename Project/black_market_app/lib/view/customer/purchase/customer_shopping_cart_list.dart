// 장바구니
import 'package:black_market_app/message/custom_dialogue.dart';
import 'package:black_market_app/vm/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CustomerShoppingCartList extends StatefulWidget {
  const CustomerShoppingCartList({super.key});

  @override
  State<CustomerShoppingCartList> createState() =>
      _CustomerShoppingCartListState();
}

class _CustomerShoppingCartListState extends State<CustomerShoppingCartList> {
  late DatabaseHandler handler;
  final box = GetStorage();
  late String uid;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    initStorage();
  }

  initStorage() {
    uid = box.read('uid');
    isReady = true;
    setState(() {});
  }

  // ------------------------- //
  Future<void> deleteCartItem(int purchaseId) async {
    await handler.deletePurchaseItem(purchaseId); // DB에서 삭제
    setState(() {});
  }

  // ------------------------- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: handler.queryShoppingCart(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('장바구니가 비어 있습니다.'));
          }
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('삭제 확인'),
                              content: const Text('정말로 장바구니에서 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(), // 취소
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await deleteCartItem(
                                      snapshot.data![index].purchaseId,
                                    );
                                    Get.back(); // 다이얼로그 닫기
                                  },
                                  child: const Text(
                                    '삭제',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: '삭제',
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      creditDialogue(
                        snapshot.data![index].productsName,
                        snapshot.data![index].purchaseQuantity,
                        snapshot.data![index].purchasePrice,
                        snapshot.data![index].storeName,
                        snapshot.data![index].purchaseId,
                      );
                    },
                    child: Card(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.memory(
                              snapshot.data![index].productsImage,
                              width: 80,
                              height: 80,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '제품명 : ${snapshot.data![index].productsName}',
                              ),
                              Text(
                                '수량    : ${snapshot.data![index].purchaseQuantity} 개',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  } // build

  creditDialogue(
    String productName,
    int quantity,
    int price,
    String storeName,
    int purchaseId,
  ) {
    CustomDialogue().showDialogue(
      title: '구매 진행',
      middleText: '''
      선택하신 상품은 $productName 이며
      $quantity 개, 가격은 $price 원 입니다.
      픽업 장소 : $storeName 으로 주문 하시겠습니까? 
      ''',
      cancelText: '취소',
      onCancel: () => Get.back(),
      confirmText: '구매요청',
      onConfirm: () async {
        await addPurchaseList(purchaseId);
        Get.back();
      },
    );
  }

  // ----------------------------------- //
  addPurchaseList(int purchaseId) async {
    await handler.updatePurchaseList(purchaseId, '주문완료');
  }

  // ----------------------------------- //
} // class
