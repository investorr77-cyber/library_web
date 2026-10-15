import 'dart:async';

import 'package:flutter/material.dart';

/// Текстовое поле, которое сообщает об изменении только после паузы во вводе.
/// Так поиск не запускает выборку на каждое нажатие клавиши.
class DebouncedField extends StatefulWidget {
  const DebouncedField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.icon,
    this.width = 260,
    this.numeric = false,
    this.delay = const Duration(milliseconds: 400),
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final IconData? icon;
  final double width;
  final bool numeric;
  final Duration delay;

  @override
  State<DebouncedField> createState() => _DebouncedFieldState();
}

class _DebouncedFieldState extends State<DebouncedField> {
  late final _controller = TextEditingController(text: widget.value);
  Timer? _timer;

  @override
  void didUpdateWidget(DebouncedField old) {
    super.didUpdateWidget(old);
    // Значение поменялось снаружи (кнопка «назад», сброс фильтров) —
    // показываем его, если пользователь сейчас не печатает.
    if (widget.value != _controller.text && !(_timer?.isActive ?? false)) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _timer?.cancel();
    _timer = Timer(widget.delay, () => widget.onChanged(text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: _controller,
        keyboardType: widget.numeric ? TextInputType.number : null,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.icon == null ? null : Icon(widget.icon),
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Очистить',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _timer?.cancel();
                    _controller.clear();
                    widget.onChanged('');
                  },
                ),
        ),
        onChanged: (t) {
          setState(() {}); // показать или скрыть крестик
          _onChanged(t);
        },
      ),
    );
  }
}
