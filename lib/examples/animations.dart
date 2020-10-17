import 'package:flutter/material.dart';

class AnimationsPageOne extends StatefulWidget {
  @override
  _AnimationsPageOneState createState() => _AnimationsPageOneState();
}


class _AnimationsPageOneState extends State<AnimationsPageOne> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _bounceAnimation;

  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(seconds: 1),
    )
    ..addListener(() {
      setState(() {});
    });

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 200.0,
    ).animate(
        CurvedAnimation(
        parent: _controller,
        curve: Curves.slowMiddle,
      )
    );

    _controller.repeat();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var distFromDeck = ((_bounceAnimation.value < 100)
                        ? _bounceAnimation.value
                        : (200 - _bounceAnimation.value));

    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurple,
            ),
            width: 40.0,
            height: 40.0,
          ),
          builder: (BuildContext context, Widget child) {
            return Column(
              children: [
                SizedBox(
                  height: (200 - distFromDeck),
                ),
                child,
                SizedBox(
                  height: distFromDeck,
                ),
                Container(
                  height: 5,
                  width: 80,
                  color: Colors.black,
                ),
              ],
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, _) =>
                  AnimationsPageTwo(transitionAnimation: animation),
              transitionDuration: Duration(seconds: 1),
            ),
          );
        },
        child: Icon(Icons.keyboard_arrow_left),
      ),
    );
  }
}

class AnimationsPageTwo extends StatelessWidget {
  final Animation<double> transitionAnimation;

  const AnimationsPageTwo({this.transitionAnimation});

  Widget _slidingContainer({@required Listenable animation,
                            @required Color color,
                            @required Offset startOffset,
                            @required Offset endOffset,
                            @required Interval animationCurve}) {
    return AnimatedBuilder(
      animation: animation,
      child: Container(
        color: color,
      ),
      builder: (context, child) =>
        SlideTransition(
          child: child,
          position: Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: animationCurve,
            ),
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: _slidingContainer(
              animation: transitionAnimation,
              color: Colors.purpleAccent,
              startOffset: Offset(1,0),
              endOffset: Offset(0,0),
              animationCurve: Interval(0, 0.5, curve: Curves.easeOut),
            ),
          ),
          Expanded(
            child: _slidingContainer(
              animation: transitionAnimation,
              color: Colors.deepPurpleAccent,
              startOffset: Offset(-1,0),
              endOffset: Offset(0,0),
              animationCurve: Interval(0.5, 1, curve: Curves.easeOut),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pop();
        },
        label: Text('Navigate Back'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}