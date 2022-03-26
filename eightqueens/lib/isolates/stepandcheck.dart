List<int> liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];

void step() {
  liPos[0]++;
  if (8 < liPos[0]) {
    liPos[0] = 1;
    liPos[1]++;
    if (8 < liPos[1]) {
      liPos[1] = 1;
      liPos[2]++;
      if (8 < liPos[2]) {
        liPos[2] = 1;
        liPos[3]++;
        if (8 < liPos[3]) {
          liPos[3] = 1;
          liPos[4]++;
          if (8 < liPos[4]) {
            liPos[4] = 1;
            liPos[5]++;
            if (8 < liPos[5]) {
              liPos[5] = 1;
              liPos[6]++;
              if (8 < liPos[6]) {
                liPos[6] = 1;
                liPos[7]++;
                if (8 < liPos[7]) {
                  liPos[7] = 1;
                }
              }
            }
          }
        }
      }
    }
  }
}

bool checkQueensNoAttack() {
  bool bNoAttack = true;
  List<int> liSum = <int>[0, 0, 0, 0, 0, 0, 0, 0];
  for (int i = 0; i < 8; i++) {
    if (1 == liPos[i]) {
      liSum[0]++;
      if (1 < liSum[0]) {
        bNoAttack = false;
        break;
      }
    }
    if (2 == liPos[i]) {
      liSum[1]++;
      if (1 < liSum[1]) {
        bNoAttack = false;
        break;
      }
    }
    if (3 == liPos[i]) {
      liSum[2]++;
      if (1 < liSum[2]) {
        bNoAttack = false;
        break;
      }
    }
    if (4 == liPos[i]) {
      liSum[3]++;
      if (1 < liSum[3]) {
        bNoAttack = false;
        break;
      }
    }
    if (5 == liPos[i]) {
      liSum[4]++;
      if (1 < liSum[4]) {
        bNoAttack = false;
        break;
      }
    }
    if (6 == liPos[i]) {
      liSum[5]++;
      if (1 < liSum[5]) {
        bNoAttack = false;
        break;
      }
    }
    if (7 == liPos[i]) {
      liSum[6]++;
      if (1 < liSum[6]) {
        bNoAttack = false;
        break;
      }
    }
    if (8 == liPos[i]) {
      liSum[7]++;
      if (1 < liSum[7]) {
        bNoAttack = false;
        break;
      }
    }
  }
  if (bNoAttack) {
    liSum = <int>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    for (int i = -6; i < 7; i++) {
      // i: column
      for (int j = 0; j < 8; j++) {
        // j: row
        if (((i + j) > -1) && ((i + j) < 8) && (i + j + 1 == liPos[j])) {
          liSum[i + 6]++;
          if (1 < liSum[i + 6]) {
            bNoAttack = false;
            break;
          }
        }
      }
      if (!bNoAttack) break;
    }
  }
  if (bNoAttack) {
    liSum = <int>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    for (int i = 1; i < 13; i++) {
      // i: column
      for (int j = 0; j < 8; j++) {
        // j: row
        if (((i - j) > -1) && ((i - j) < 8) && (i - j + 1 == liPos[j])) {
          liSum[i - 1]++;
          if (1 < liSum[i - 1]) {
            bNoAttack = false;
            break;
          }
        }
      }
      if (!bNoAttack) break;
    }
  }
  return bNoAttack;
}
