module porter_stemmer;

import std.typecons;
import std.string;
import std.array;
import std.stdio;

string stem(T)(in T inS){
    string s = inS.toLower();
    auto mc = mCount(inS);

    //step 1a
    if( s.length > 4 && s[$-4..$] == "sses"){
        s.length -= 2;
        replaceInPlace(s, s.length-2, s.length, "ss");
    } else if( s.length > 3 && s[$-3..$] == "ies"){
        s.length -= 2;
        replaceInPlace(s, s.length-1, s.length, "i");
    } else if(s.length > 2 && s[$-2..$] == "ss"){
    } else if(s.length > 1 && s[$-1..$] == "s"){
        s.length --;
    }


    //step 1b
    if(mc > 0 && s.length > 3 && s[$-3..$] == "eed"){
      s.length--;
      replaceInPlace(s, s.length-2, s.length, "ee");
    }

    return s;
}

/*
  returns the mcount for the given word
*/
int mCount(T)(in T word){
  int m = 0;
  auto isV = isVowel(word, 0);

  for(int i = 1; i < word.length; i++){
    auto newV = isVowel(word, i);
    
    // count up the number of vowel sets found
    if(newV && !isV){
      m++;
    }

    isV = newV;
  }

  // subtract 1 for trailing vowel
  if(isV){
    m--;
  }

  return m;
}

/*
  Returns true if the letter at
  the passed index is a vowel
*/
bool isVowel(T)(in T word, int index){
  switch(word[index]){
    case 'a':
    case 'A':
    case 'e':
    case 'E':
    case 'i':
    case 'I':
    case 'o':
    case 'O':
    case 'u':
    case 'U':
        return true;
    case 'y':
    case 'Y':
        return index > 0 && !isVowel(word, index-1);
    default:
        return false;

  } 
}


unittest {
    // cases are just pairs onf expected outputs
    auto cases = [
        // 1a
        /*tuple("caresses", "caress"),
        tuple("ties", "ti"),
        tuple("cats", "cat"),
        tuple("ponies", "poni"),*/
        //1b
        tuple("feed", "feed"),
        tuple("agreed", "agree"),
    ];

    foreach(c; cases){
        assert(stem(c[0]) == c[1],
            "Expected '"~c[0]~"' to stem to '"~c[1]~"' got '"~stem(c[0])~"'");
    }
}

unittest {
    import std.conv;

    auto cases = [
      tuple("tr", 0),
      tuple("ee", 0),
      tuple("feed", 0),
      tuple("tree", 0),
      tuple("y", 0),
      tuple("by", 0),
      tuple("trouble", 1),
      tuple("oats", 1),
      tuple("trees", 1),
      tuple("ivy", 1),
      tuple("troubles", 2),
      tuple("private", 2),
      tuple("oaten", 2),
      tuple("orrery", 2),
    ];

    foreach(c; cases){
      assert(mCount(c[0]) == c[1], 
          "Expected '"~c[0]~"' to have an mcount '"~to!(string)(c[1])~"' got '"~to!(string)(mCount(c[0]))~"'");

    }
}

unittest {
    auto cases = [
      tuple("caresses", 0, false),
      tuple("caresses", 1, true),
      tuple("caresses", 3, true),
      tuple("caresses", 4, false),
      tuple("caresses", 6, true),
      tuple("cray", 3, false),
      tuple("try", 2, true),
      tuple("yak", 0, false)
    ];

    foreach(c; cases){
      auto msg = c[2] ? "Expected '"~c[0][c[1]]~"' in '"~c[0]~"' to be a vowel " :
                        "Expected '"~c[0][c[1]]~"' in '"~c[0]~"' not to be a vowel ";
      assert(isVowel(c[0], c[1]) == c[2], msg);
    }

}

