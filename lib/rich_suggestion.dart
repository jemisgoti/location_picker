import 'package:flutter/material.dart';

class RichSuggestion extends StatelessWidget {
  final VoidCallback onTap;
  final AutoCompleteItem autoCompleteItem;

  RichSuggestion(this.autoCompleteItem, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
            child: 
            ListTile(
          // dense: true,
          leading: Container(
            width: 30,
            height: 30,
            padding: EdgeInsets.all(3),
            child: Center(
              child: Icon(
                Icons.location_pin,
                color: Colors.black,
                size: 18,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
          title:RichText(
                    text: TextSpan(children: getStyledTexts(context)),
                  ),
          // subtitle:
          //     Text(autoCompleteItem.text!.split(", ").sublist(1).join(', ')),
        )
            // Row(
            //   children: <Widget>[
            //     Expanded(
            //       child: RichText(
            //         text: TextSpan(children: getStyledTexts(context)),
            //       ),
            //     )
            //   ],
            // )

            ),
      ),
    );
  }

  List<TextSpan> getStyledTexts(BuildContext context) {
    final List<TextSpan> result = [];

    String startText =
        autoCompleteItem.text!.substring(0, autoCompleteItem.offset);
    if (startText.isNotEmpty) {
      result.add(
        TextSpan(
          text: startText,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    String boldText = autoCompleteItem.text!.substring(autoCompleteItem.offset!,
        autoCompleteItem.offset! + autoCompleteItem.length!);

    result.add(
      TextSpan(
        text: boldText,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    String remainingText = this
        .autoCompleteItem
        .text!
        .substring(autoCompleteItem.offset! + autoCompleteItem.length!);
    result.add(
      TextSpan(
        text: remainingText,
        style: TextStyle(color: Colors.grey, fontSize: 15),
      ),
    );

    return result;
  }
}

/// Autocomplete results item returned from Google will be deserialized
/// into this model.
class AutoCompleteItem {
  /// The id of the place. This helps to fetch the lat,lng of the place.
  String? id;

  /// The text (name of place) displayed in the autocomplete suggestions list.
  String? text;

  /// Assistive index to begin highlight of matched part of the [text] with
  /// the original query
  int? offset;

  /// Length of matched part of the [text]
  int? length;

  @override
  String toString() {
    return 'AutoCompleteItem{id: $id, text: $text, offset: $offset, length: $length}';
  }
}
