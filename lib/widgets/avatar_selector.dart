import 'package:flutter/material.dart';

class AvatarSelector extends StatefulWidget {
  final String? currentAvatar;
  final Function(String) onAvatarSelected;

  const AvatarSelector({
    super.key,
    this.currentAvatar,
    required this.onAvatarSelected,
  });

  @override
  _AvatarSelectorState createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  final List<String> _avatars = [
    'boy.PNG',
    'girl.PNG',
    'can.PNG',
    'pan.PNG',
    'ring.PNG',
    'slipper.PNG',
  ];

  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.currentAvatar ?? 'boy.PNG';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = (size.width * 0.6).clamp(320.0, 500.0);
    final dialogMaxHeight = size.height * 0.85;
    final crossCount = dialogWidth >= 420 ? 3 : 2;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: dialogMaxHeight,
        ),
        decoration: BoxDecoration(
          color: const Color(0xF9DD9A00),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xAD572100), width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Your Avatar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 20),

              // Avatar grid
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = _avatars[index];
                    final isSelected = avatar == _selectedAvatar;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = avatar),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.brown,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? const Color(0xAD572100)
                              : Colors.transparent,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            'assets/avatar/$avatar',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.brown),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.onAvatarSelected(_selectedAvatar!);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2FB998),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Select'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
