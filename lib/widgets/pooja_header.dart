import 'package:flutter/material.dart';

class PoojaHeader extends StatefulWidget {
  const PoojaHeader({
    super.key,
    this.title = 'Pooja',
    this.onMenuTap,
    this.onSearchChanged,
  });

  final String title;
  final VoidCallback? onMenuTap;
  final ValueChanged<String>? onSearchChanged;

  @override
  State<PoojaHeader> createState() => _PoojaHeaderState();
}

class _PoojaHeaderState extends State<PoojaHeader> with SingleTickerProviderStateMixin {
  bool _searching = false;
  late final TextEditingController _ctrl;
  late final AnimationController _anim;
  late final Animation<double> _expand;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _expand = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searching = true);
    _anim.forward();
  }

  void _closeSearch() {
    _anim.reverse().then((_) {
      setState(() => _searching = false);
      _ctrl.clear();
      widget.onSearchChanged?.call('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Menu / back button
              InkWell(
                onTap: _searching ? _closeSearch : widget.onMenuTap,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _searching ? Icons.arrow_back : Icons.menu,
                    size: 28,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title always on left; search bar overlays it when expanded
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Title
                    AnimatedOpacity(
                      opacity: _searching ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Expandable search bar
                    SizeTransition(
                      sizeFactor: _expand,
                      axis: Axis.horizontal,
                      axisAlignment: -1,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          autofocus: _searching,
                          onChanged: widget.onSearchChanged,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                          decoration: InputDecoration(
                            hintText: 'Search poojas…',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search / close icon
              InkWell(
                onTap: _searching ? _closeSearch : _openSearch,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _searching ? Icons.close : Icons.search,
                    size: 26,
                    color: Colors.black87,
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
