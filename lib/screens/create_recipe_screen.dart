
import 'package:flutter/material.dart';
import 'package:kitchensop/database/database_helper.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() =>
      _CreateRecipeScreenState();
}

class _CreateRecipeScreenState
    extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController categoryController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController preparationTimeController =
      TextEditingController();

  final TextEditingController ingredientsController =
      TextEditingController();

  final TextEditingController preparationStepsController =
      TextEditingController();

  final TextEditingController cookingInstructionsController =
      TextEditingController();

  final TextEditingController storageInstructionsController =
      TextEditingController();

  final TextEditingController freezingInstructionsController =
      TextEditingController();

  final TextEditingController thawingInstructionsController =
      TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    preparationTimeController.dispose();
    ingredientsController.dispose();
    preparationStepsController.dispose();
    cookingInstructionsController.dispose();
    storageInstructionsController.dispose();
    freezingInstructionsController.dispose();
    thawingInstructionsController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE RECIPE
  // ============================================================

  Future<void> saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final preparationTime =
        int.tryParse(
          preparationTimeController.text.trim(),
        ) ??
        0;

    if (preparationTime <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid preparation time.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await DatabaseHelper.instance.insertRecipe(
        name: nameController.text.trim(),

        category: categoryController.text.trim(),

        description:
            descriptionController.text.trim(),

        image: '',

        preparationTime: preparationTime,

        ingredients:
            ingredientsController.text.trim(),

        preparationSteps:
            preparationStepsController.text.trim(),

        cookingInstructions:
            cookingInstructionsController.text.trim(),

        storageInstructions:
            storageInstructionsController.text.trim(),

        freezingInstructions:
            freezingInstructionsController.text.trim(),

        thawingInstructions:
            thawingInstructionsController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recipe saved successfully!',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save recipe: $e',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType =
        TextInputType.text,
    bool requiredField = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,

        decoration: InputDecoration(
          labelText: label,
          hintText: hint,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide:
                const BorderSide(
              color: Colors.grey,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide:
                const BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),

        validator: requiredField
            ? (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return '$label is required';
                }

                return null;
              }
            : null,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Recipe',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Recipe Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                buildTextField(
                  label: 'Recipe Name',
                  hint:
                      'e.g. Classic Beef Burger',
                  controller:
                      nameController,
                ),

                buildTextField(
                  label: 'Category',
                  hint:
                      'e.g. Burgers, Pizza, Drinks',
                  controller:
                      categoryController,
                ),

                buildTextField(
                  label: 'Description',
                  hint:
                      'Describe the recipe',
                  controller:
                      descriptionController,
                  maxLines: 4,
                ),

                buildTextField(
                  label:
                      'Preparation Time',
                  hint:
                      'Enter time in minutes',
                  controller:
                      preparationTimeController,
                  keyboardType:
                      TextInputType.number,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                buildTextField(
                  label: 'Ingredients',
                  hint:
                      'Enter ingredients, one per line',
                  controller:
                      ingredientsController,
                  maxLines: 7,
                ),

                const Text(
                  'Preparation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                buildTextField(
                  label:
                      'Preparation Steps',
                  hint:
                      'Enter preparation steps',
                  controller:
                      preparationStepsController,
                  maxLines: 8,
                ),

                const Text(
                  'Cooking',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                buildTextField(
                  label:
                      'Cooking Instructions',
                  hint:
                      'Enter cooking instructions',
                  controller:
                      cookingInstructionsController,
                  maxLines: 8,
                ),

                const Text(
                  'Storage',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                buildTextField(
                  label:
                      'Storage Instructions',
                  hint:
                      'How should the recipe/product be stored?',
                  controller:
                      storageInstructionsController,
                  maxLines: 5,
                  requiredField: false,
                ),

                const Text(
                  'Freezing',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                buildTextField(
                  label:
                      'Freezing Instructions',
                  hint:
                      'Explain freezing procedure',
                  controller:
                      freezingInstructionsController,
                  maxLines: 5,
                  requiredField: false,
                ),

                const Text(
                  'Thawing',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                buildTextField(
                  label:
                      'Thawing Instructions',
                  hint:
                      'Explain thawing procedure',
                  controller:
                      thawingInstructionsController,
                  maxLines: 5,
                  requiredField: false,
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton.icon(
                    onPressed:
                        isSaving
                            ? null
                            : saveRecipe,

                    icon: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.save,
                          ),

                    label: Text(
                      isSaving
                          ? 'Saving...'
                          : 'Save Recipe',
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
