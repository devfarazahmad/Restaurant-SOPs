import 'package:flutter/material.dart';

import 'package:kitchensop/database/database_helper.dart';
import 'package:kitchensop/models/recipe.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<EditRecipeScreen> createState() =>
      _EditRecipeScreenState();
}

class _EditRecipeScreenState
    extends State<EditRecipeScreen> {

  final _formKey =
      GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;
  late TextEditingController preparationTimeController;
  late TextEditingController ingredientsController;
  late TextEditingController preparationStepsController;
  late TextEditingController cookingInstructionsController;
  late TextEditingController storageInstructionsController;
  late TextEditingController freezingInstructionsController;
  late TextEditingController thawingInstructionsController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final recipe = widget.recipe;

    nameController =
        TextEditingController(
      text: recipe.name,
    );

    categoryController =
        TextEditingController(
      text: recipe.category,
    );

    descriptionController =
        TextEditingController(
      text: recipe.description,
    );

    preparationTimeController =
        TextEditingController(
      text: recipe.preparationTime.toString(),
    );

    ingredientsController =
        TextEditingController(
      text: recipe.ingredients,
    );

    preparationStepsController =
        TextEditingController(
      text: recipe.preparationSteps,
    );

    cookingInstructionsController =
        TextEditingController(
      text: recipe.cookingInstructions,
    );

    storageInstructionsController =
        TextEditingController(
      text: recipe.storageInstructions,
    );

    freezingInstructionsController =
        TextEditingController(
      text: recipe.freezingInstructions,
    );

    thawingInstructionsController =
        TextEditingController(
      text: recipe.thawingInstructions,
    );
  }

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

  // ==========================================
  // SAVE CHANGES
  // ==========================================
  Future<void> updateRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await DatabaseHelper.instance.updateRecipe(
        id: widget.recipe.id,
        name: nameController.text,
        category: categoryController.text,
        description:
            descriptionController.text,
        image: widget.recipe.image,
        preparationTime:
            int.tryParse(
                  preparationTimeController.text,
                ) ??
                0,
        ingredients:
            ingredientsController.text,
        preparationSteps:
            preparationStepsController.text,
        cookingInstructions:
            cookingInstructionsController.text,
        storageInstructions:
            storageInstructionsController.text,
        freezingInstructions:
            freezingInstructionsController.text,
        thawingInstructions:
            thawingInstructionsController.text,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Update failed: $e'),
        ),
      );
    }
  }

  // ==========================================
  // FIELD
  // ==========================================
  Widget field({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w700,
            color:
                Color(0xFF374151),
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        TextFormField(
          controller:
              controller,
          maxLines:
              maxLines,
          keyboardType:
              keyboardType,
          decoration:
              InputDecoration(
            hintText:
                hint,
            filled:
                true,
            fillColor:
                Colors.white,
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  const BorderSide(
                color:
                    Color(0xFFE5E7EB),
              ),
            ),
          ),
          validator:
              (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return
                  '$label is required';
            }

            return null;
          },
        ),

        const SizedBox(
          height: 18,
        ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF9FAFB,
      ),

      appBar: AppBar(
        backgroundColor:
            const Color(
          0xFFF9FAFB,
        ),
        elevation: 0,
        title:
            const Text(
          'Edit Recipe',
          style:
              TextStyle(
            color:
                Color(
              0xFF111827,
            ),
            fontWeight:
                FontWeight.bold,
          ),
        ),
        iconTheme:
            const IconThemeData(
          color:
              Color(
            0xFF111827,
          ),
        ),
      ),

      body:
          Form(
        key:
            _formKey,
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            40,
          ),
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              const Text(
                'Recipe Information',
                style:
                    TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(
                    0xFF111827,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              field(
                label:
                    'Recipe Name',
                hint:
                    'Recipe name',
                controller:
                    nameController,
              ),

              field(
                label:
                    'Category',
                hint:
                    'Category',
                controller:
                    categoryController,
              ),

              field(
                label:
                    'Description',
                hint:
                    'Description',
                controller:
                    descriptionController,
                maxLines:
                    4,
              ),

              field(
                label:
                    'Preparation Time (minutes)',
                hint:
                    '15',
                controller:
                    preparationTimeController,
                keyboardType:
                    TextInputType.number,
              ),

              field(
                label:
                    'Ingredients',
                hint:
                    'One ingredient per line',
                controller:
                    ingredientsController,
                maxLines:
                    8,
              ),

              field(
                label:
                    'Preparation Steps',
                hint:
                    'Step-by-step preparation',
                controller:
                    preparationStepsController,
                maxLines:
                    8,
              ),

              field(
                label:
                    'Cooking Instructions',
                hint:
                    'Cooking instructions',
                controller:
                    cookingInstructionsController,
                maxLines:
                    8,
              ),

              field(
                label:
                    'Storage Instructions',
                hint:
                    'Storage instructions',
                controller:
                    storageInstructionsController,
                maxLines:
                    5,
              ),

              field(
                label:
                    'Freezing Instructions',
                hint:
                    'Freezing instructions',
                controller:
                    freezingInstructionsController,
                maxLines:
                    5,
              ),

              field(
                label:
                    'Thawing Instructions',
                hint:
                    'Thawing instructions',
                controller:
                    thawingInstructionsController,
                maxLines:
                    5,
              ),

              const SizedBox(
                height: 5,
              ),

              SizedBox(
                width:
                    double.infinity,
                height:
                    55,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      isSaving
                          ? null
                          : updateRecipe,
                  icon:
                      isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons
                                  .save_rounded,
                            ),
                  label:
                      Text(
                    isSaving
                        ? 'Saving...'
                        : 'Save Changes',
                    style:
                        const TextStyle(
                      fontSize:
                          16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFF59E0B,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation:
                        0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}