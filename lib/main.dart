import 'package:flutter/material.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Заметки')),
        body: const NotesWidget(),
      ),
    );
  }
}

class NotesWidget extends StatefulWidget {
  const NotesWidget({super.key});

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _notes = [];
  final List<bool> _important = [];
  int _editIndex = -1;
  double _swipeDx = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_controller.text.isEmpty) return;
    setState(() {
      if (_editIndex == -1) {
        _notes.add(_controller.text);
        _important.add(false);
      } else {
        _notes[_editIndex] = _controller.text;
        _editIndex = -1;
      }
    });
    _controller.clear();
  }

  void _openNote(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Заметка'),
          content: Text(_notes[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _markImportant(int index) {
    setState(() {
      _important[index] = true;
    });
  }

  void _editNote(int index) {
    setState(() {
      _editIndex = index;
    });
    _controller.text = _notes[index];
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      _important.removeAt(index);
      _editIndex = -1;
    });
    _controller.clear();
  }

  void _restoreNote(int index) {
    setState(() {
      _important[index] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Введите текст заметки',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saveNote,
            child: Text(_editIndex == -1 ? 'Сохранить' : 'Сохранить изменения'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openNote(index),
                  onDoubleTap: () => _markImportant(index),
                  onLongPress: () => _editNote(index),
                  onHorizontalDragStart: (details) {
                    _swipeDx = 0;
                  },
                  onHorizontalDragUpdate: (details) {
                    _swipeDx += details.delta.dx;
                  },
                  onHorizontalDragEnd: (details) {
                    if (_swipeDx < -50) {
                      _deleteNote(index);
                    } else if (_swipeDx > 50) {
                      _restoreNote(index);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: _important[index]
                          ? Colors.amber.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: _important[index]
                          ? const Icon(Icons.star, color: Colors.orange)
                          : null,
                      title: Text(
                        _notes[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}