import 'package:flutter/material.dart';

class ProductFilterSheet extends StatelessWidget {
  final String type;
  final String currentValue;

  const ProductFilterSheet({
    super.key,
    required this.type,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    List<String> options;

    if (type == 'category') {
      options = [
        'Все',
        'Уход за кожей',
        'Декоративная косметика',
        'Уход за волосами',
        'Парфюмерия',
        'Уход за телом',
        'Уход за ногтями',
      ];
    } else {
      options = [
        'Все',
        'L\'Oreal',
        'Maybelline',
        'Revlon',
        'MAC',
        'Estee Lauder',
        'Clinique',
        'NARS',
        'Urban Decay',
      ];
    }

    final itemHeight = 56.0; // Высота одного ListTile
    final headerHeight = 80.0; // Высота заголовка и отступов
    final totalHeight = (options.length * itemHeight) + headerHeight;
    final maxHeight = MediaQuery.of(context).size.height * 0.6;
    final sheetHeight = totalHeight > maxHeight ? maxHeight : totalHeight;

    return Container(
      height: sheetHeight,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите ${type == 'category' ? 'категорию' : 'бренд'}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return ListTile(
                  title: Text(option),
                  trailing: option == currentValue
                      ? const Icon(Icons.check, color: Color(0xFFE91E63))
                      : null,
                  onTap: () => Navigator.pop(context, option),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

