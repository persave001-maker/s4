
import 'package:flutter/material.dart';

void main() {
  runApp(const SupermarketApp());
}

class SupermarketApp extends StatelessWidget {
  const SupermarketApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'سوپرمارکت جیبی',
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MainDashboard(),
    );
  }
}

class Product {
  String code;
  String name;
  int stock;
  double price;
  Product({required this.code, required this.name, required this.stock, required this.price});
}

class Customer {
  String mobile;
  String name;
  Customer({required this.mobile, required this.name});
}

class CartItem {
  Product product;
  int quantity;
  CartItem({required this.product, required this.quantity});
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  List<Product> products = [
    Product(code: '101', name: 'شیر کم چرب', stock: 20, price: 35000),
    Product(code: '102', name: 'ماست دبه‌ای', stock: 15, price: 90000),
    Product(code: '103', name: 'نان تست', stock: 30, price: 25000),
  ];

  List<Customer> customers = [
    Customer(mobile: '09121234567', name: 'مشترک قدیمی ۱'),
  ];

  String currentCustomerMobile = '';
  List<CartItem> cart = [];

  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final FocusNode _productFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();

  String sellerCardNumber = "۶۰۳۷۹۹۱۸۱۲۳۴۵۶۷۸";

  double get totalPrice {
    return cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void _addInfoToCart() {
    String pCode = _productCodeController.text.trim();
    int qty = int.tryParse(_quantityController.text.trim()) ?? 1;

    var prodIndex = products.indexWhere((p) => p.code == pCode);
    if (prodIndex != -1) {
      if (products[prodIndex].stock >= qty) {
        setState(() {
          cart.add(CartItem(product: products[prodIndex], quantity: qty));
          products[prodIndex].stock -= qty;
        });
        _productCodeController.clear();
        _quantityController.clear();
        FocusScope.of(context).requestFocus(_productFocusNode);
      } else {
        _showSnackBar('موجودی انبار کافی نیست! موجودی: ${products[prodIndex].stock}');
      }
    } else {
      _showSnackBar('کالایی با این کد یافت نشد!');
    }
  }

  void _checkAndRegisterCustomer(String mobile) {
    if (mobile.isEmpty) return;
    currentCustomerMobile = mobile;
    var exists = customers.any((c) => c.mobile == mobile);
    if (!exists) {
      setState(() {
        customers.add(Customer(mobile: mobile, name: 'مشترک جدید'));
      });
      _showSnackBar('شماره جدید! به عنوان مشترک جدید ثبت شد.');
    }
    FocusScope.of(context).requestFocus(_productFocusNode);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('سوپرمارکت جیبی (نسخه مغازه)',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory, color: Colors.white),
            onPressed: _openInventory,
          ),
          IconButton(
            icon: const Icon(Icons.people, color: Colors.white),
            onPressed: _openCustomers,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _customerController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'شماره موبایل مشترک (کد مشترک)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              onSubmitted: (value) => _checkAndRegisterCustomer(value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _productCodeController,
                    focusNode: _productFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'کد کالا',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_quantityFocusNode),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _quantityController,
                    focusNode: _quantityFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'تعداد',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addInfoToCart(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addInfoToCart,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 20)),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text('سبد خرید فعلی:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.product.name),
                      subtitle: Text(
                          'کد: ${item.product.code} | تعداد: ${item.quantity}'),
                      trailing: Text(
                          '${(item.product.price * item.quantity).toStringAsFixed(0)} تومان'),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('جمع کل فاکتور:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${totalPrice.toStringAsFixed(0)} تومان',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: cart.isEmpty ? null : _showInvoiceDialog,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('بستن سبد و نمایش فاکتور',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceDialog() {
    String textInvoice = "فاکتور خرید شما\n";
    for (var item in cart) {
      textInvoice +=
          "${item.product.name} (${item.quantity}عدد): ${(item.product.price * item.quantity).toStringAsFixed(0)}ت\n";
    }
    textInvoice += "------------------\nجمع کل: ${totalPrice.toStringAsFixed(0)} تومان\n";
    textInvoice += "شماره کارت جهت واریز:\n$sellerCardNumber";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('فاکتور نهایی'),
        content: SingleChildScrollView(child: Text(textInvoice)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                cart.clear();
                _customerController.clear();
                currentCustomerMobile = '';
              });
              Navigator.pop(ctx);
              _showSnackBar('فاکتور آماده ارسال شد.');
            },
            child: const Text('تایید و بستن فاکتور'),
          ),
        ],
      ),
    );
  }

  void _openInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text('موجودی انبار و کالاها',
                  style: TextStyle(color: Colors.white))),
          body: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(products[i].name),
              subtitle:
                  Text('کد: ${products[i].code} | موجودی: ${products[i].stock} عدد'),
              trailing: Text('${products[i].price.toStringAsFixed(0)} تومان'),
            ),
          ),
        ),
      ),
    );
  }

  void _openCustomers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text('لیست مشترکین',
                  style: TextStyle(color: Colors.white))),
          body: ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(customers[i].name),
              subtitle: Text('شماره موبایل: ${customers[i].mobile}'),
            ),
          ),
        ),
      ),
    );
  }
}