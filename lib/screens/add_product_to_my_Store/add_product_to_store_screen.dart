import 'package:flutter/material.dart';
import 'package:zawasna_project/controllers/products_controller.dart';
import 'package:zawasna_project/models/product.dart';
import 'package:zawasna_project/shared/components/default_button.dart';
import 'package:zawasna_project/shared/components/default_text_form.dart';
import 'package:provider/provider.dart';

class AddProductToMyStoreScreen extends StatefulWidget {
  @override
  State<AddProductToMyStoreScreen> createState() =>
      _AddProductToMyStoreScreenState();
}

class _AddProductToMyStoreScreenState extends State<AddProductToMyStoreScreen> {
  var text_productNameController = TextEditingController();
  var text_qty_controller = TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isEnable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product To Store"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    height: 50,
                    child: Autocomplete<ProductModel>(
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                        final options = await context
                            .read<ProductsController>()
                            .autocomplete_Search_forProduct(
                                textEditingValue.text);
                        return options;
                      },
                      displayStringForOption: (option) =>
                          option.name.toString(),
                      onSelected: (suggestion) {
                        text_productNameController.text =
                            suggestion.name.toString();
                        setState(() {
                          _isEnable = false;
                        });
                      },
                    ),
                  ),
                  !_isEnable
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              text_productNameController.clear();
                              _isEnable = true;
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.red.shade500,
                          ))
                      : SizedBox(
                          width: 2,
                        ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              defaultTextFormField(
                  controller: text_qty_controller,
                  onvalidate: (value) {
                    if (value!.isEmpty) {
                      return "Quantity must not be empty";
                    }
                    return null;
                  },
                  inputtype: TextInputType.phone,
                  border: UnderlineInputBorder(),
                  hinttext: "Quantity"),
              SizedBox(
                height: 10,
              ),
              defaultButton(
                  text: "Save",
                  onpress: () async {
                    // Your save logic here
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
