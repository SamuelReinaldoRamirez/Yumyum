import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/widget/neu_brutalism_container.dart';
import '../../models/booking_data.dart';
import '../neubrutalist/neubrutalist_button.dart';

class BookingStepTwo extends StatefulWidget {
  final BookingData bookingData;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const BookingStepTwo({
    Key? key,
    required this.bookingData,
    required this.onNext,
    required this.onBack,
    required this.onClose,
  }) : super(key: key);

  @override
  State<BookingStepTwo> createState() => _BookingStepTwoState();
}

class _BookingStepTwoState extends State<BookingStepTwo> {
  String selectedTitle = 'M.';
  final _formKey = GlobalKey<FormState>();
  bool saveInfo = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Récapitulatif
                  NeuBrutalismContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Récapitulatif',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            TextButton(
                              onPressed: widget.onBack,
                              child: Text(
                                'Modifier',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildRecapItem(
                          'Date',
                          DateFormat('dd/MM/yyyy')
                              .format(widget.bookingData.date),
                          Icons.calendar_today,
                        ),
                        _buildRecapItem(
                          'Heure',
                          widget.bookingData.timeSlot,
                          Icons.access_time,
                        ),
                        _buildRecapItem(
                          'Personnes',
                          '${widget.bookingData.covers} personne${widget.bookingData.covers > 1 ? 's' : ''}',
                          Icons.person,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height:
                          40), // Augmenter l'espace entre le récapitulatif et le formulaire de contact

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.textColor,
                        onPressed: widget
                            .onBack, // Action pour revenir à l'étape précédente
                      ),
                      const SizedBox(width: 8),
                      Center(
                        child: const Text(
                          'Formulaire de contact',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Formulaire
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Civilité
                        NeuBrutalismContainer(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTitleOption('M.'),
                              _buildTitleOption('Mme'),
                              _buildTitleOption('Mx'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Conteneur pour les champs de formulaire
                        NeuBrutalismContainer(
                          child: Column(
                            children: [
                              // Nom
                              TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nom',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Veuillez entrer votre nom'
                                    : null,
                              ),

                              const SizedBox(height: 20),

                              // Prénom
                              TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Prénom',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Veuillez entrer votre prénom'
                                    : null,
                              ),

                              const SizedBox(height: 20),

                              // Téléphone
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Téléphone',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Veuillez entrer votre numéro'
                                    : null,
                              ),

                              const SizedBox(height: 20),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Veuillez entrer votre email'
                                    : null,
                              ),

                              const SizedBox(height: 20),

                              // Sauvegarder les informations
                              Row(
                                children: [
                                  Switch(
                                    value: saveInfo,
                                    onChanged: (value) {
                                      setState(() {
                                        saveInfo = value;
                                      });
                                    },
                                    activeColor: AppColors
                                        .primaryColor, // Couleur primaire quand actif
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Se souvenir de moi'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Ajouter un container avec 'easy' en dessous du formulaire
                        const SizedBox(height: 20),

                        Container(
                          alignment: Alignment.center,
                          child: NeubrutalistButton(
                            onPressed: widget.onNext,
                            height: 60,
                            backgroundColor: AppColors.primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Terminer',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                        // Ajouter un container avec 'easy' en dessous du formulaire
                        const SizedBox(height: 50),

                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'easy',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleOption(String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTitle = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selectedTitle == title
                ? AppColors.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  selectedTitle == title ? Colors.white : AppColors.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecapItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.textColor),
          ),
        ],
      ),
    );
  }
}
