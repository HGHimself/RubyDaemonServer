INF = +1.0/0.0
NINF = -1.0/0.0

class TicTacToe

  def copy_board(state)
    new_board = []
    state.each do |line|
      dupe = line.dup
      new_board << dupe
    end
    return new_board
  end


  def alphabeta(node, depth, alpha, beta, maximizingPlayer, player)
    #puts "----alphabeta---"
    if depth == 0 or terminal_test(node)
      #puts "BOTTOM"
      return evaluate(node, player)
    end
    if maximizingPlayer
      #puts "MAX"
      value = NINF
      #for each child of node do
      actions, states = successor_function(node, player)
      states.each do |child|
        value = [value, alphabeta(child, depth - 1, alpha, beta, false, player)].max
        alpha = [alpha, value].max
          if alpha >= beta
            break # beta cut-off
          end
      end
      return value
    else
      #puts "MIN"
      value = INF
      actions, states = successor_function(node, player)
      states.each do |child|
        value = [value, alphabeta(child, depth - 1, alpha, beta, true, player)].min
        beta = [beta, value].min
        if alpha >= beta
          break # alpha cut-off
        end
      end
      return value
    end
  end

  def max_value(state, player, alpha, beta, depth, max_depth)
    newDepth = depth + 1
    if cutoff_test(state, depth, max_depth)
      return evaluate(state, player)
    end
    v = NINF
    actions, states = successor_function(state, player)
    actions.each_with_index do |a, i|
      v = [v, min_value(states[i], player, alpha, beta, newDepth, max_depth)].max
      if v >= beta
        return v
      end
      alpha = [alpha, v].max
    end
    return v
  end

  def min_value(state, player, alpha, beta, depth, max_depth)
    newDepth = depth + 1
    if cutoff_test(state, depth, max_depth)
      return evaluate(state, player)
    end
    v = INF
    actions, states = successor_function(state, player)
    actions.each_with_index do |a, i|
      v = [v, max_value(states[i], player, alpha, beta, newDepth, max_depth)].min
      if v >= alpha
        return v
      end
      beta = [beta, v].min
    end
    return v
  end

  #this guy returns actions(indeces of action) and states(board after move made)
  def successor_function(board, player)
    states = []
    actions = []
    6.times do |row|
      6.times do |col|
        if board[row][col] == 0
          #copy the board and set the indeces to the player's glyph
          copiedBoard = copy_board(board)
          copiedBoard[row][col] = player
          states.push(copiedBoard)
          actions.push([row, col])
        end
      end
    end
    return actions, states
  end


  def terminal_test(state)
    result = evaluate(state, 1)
    if result.abs >= 300
      #puts "this boy terminal"
      return true
    else
      return false
    end
  end

  def cutoff_test(state, depth, max_depth)
    if depth >= max_depth or terminal_test(state)
      return true
    else
      return false
    end
  end



  def evaluate(state, player)
    len = 6
    all_sequences = []

    #first do diagonals
    #dont forget about symmetry!

    #go right to left in a downward diagonal
    len.times do |k|
      sequence = []
      sequence2 = []
      i = len - 1
      j = i - k
      (k+1).times do
        if( (j + i) == len - 1)
          sequence << state[i][j]
        else
          sequence << state[i][j]
          sequence2 << state[(j-5).abs][(i-5).abs]
        end
        i-=1
        j+=1
      end
      all_sequences << sequence
      if sequence2.size != 0
        all_sequences << sequence2
      end
    end

    (len).times do |k|
      sequence = []
      sequence2 = []
      i = 0
      j = len - 1 - k
      while i <= k
        if(i == j)
          sequence << state[i][j]
        else
          sequence << state[i][j]
          sequence2 << state[j][i]
        end
        i+=1
        j+=1
      end
      all_sequences << sequence
      if sequence2.size != 0
        all_sequences << sequence2
      end
    end


    #do both rows and columns at the same time
    (len).times do |i|
      sequence = []
      sequence2 = []
      (len).times do |j|
        sequence << state[i][j]
        sequence2 << state[j][i]
      end
      all_sequences << sequence
      if sequence2.size
        all_sequences << sequence2
      end
    end
    total = heuristic(all_sequences, player)
    return total
  end


  def heuristic(sequences, player)
    #puts sequences.size
    my = [0, 0, 0]
    opp = [0, 0, 0]
    #puts sequences.size
    sequences.each do |seq|
      #puts seq
      #puts "*" * 10
      prev = -1
      streak = 0
      seq.each_with_index do |token, i|
        #consecutives here
        if token == prev
          if token == 0
            #do nothing
            streak = 0
          else
            #this is what we want
            streak += 1
            if i == seq.size - 1
              #puts "we have a terminal streak"
              if streak >= 4
                #puts "4 block"
                if player == token
                  return 300
                else
                  return -300
                end
              else
                #check for leading zeros and dont underflow the array
                if 0 == seq[i - streak - 1]
                  if streak == 3
                    if player == token
                      my[1] += 1
                    else
                      opp[1] += 1
                    end
                  else
                    if streak == 2
                      if player == token
                        my[2] += 1
                      else
                        opp[2] += 1
                      end
                    end
                  end
                end
              end
            end
          end


        #non consecutive
        else
          #we only care about 2 and up
          if streak >= 2
            if streak >= 4
              #puts "4 block"
              if player == prev
                return 300
              else
                return -300
              end
            elsif streak == 3
              #check for leading zeros and dont underflow the array
              if i > 3 and 0 == seq[i - streak - 1]
                #check for trailing 0
                if token == 0
                  #puts "3 block w/ 2 0s"
                  if player == prev
                    my[0] += 1
                  else
                    opp[0] += 1
                  end
                else
                  #puts "3 block w/ leading 0"
                  if player == prev
                    my[1] += 1
                  else
                    opp[1] += 1
                  end
                end
              else #no leading 0
                #puts "3 block w/ trailing 0"
                if token == 0
                  if player == prev
                    my[1] += 1
                  else
                    opp[1] += 1
                  end
                end
              end
            else
              if (i > 2 and 0 == seq[i - streak - 1]) or token == 0
                #puts "2 block w/ 0s"
                if player == prev
                  my[2] += 1
                else
                  opp[2] += 1
                end
              end
            end
          end

          # this starts the new streak for non 0
          if token == 0
            streak = 0
          else
            #puts "starting the streak"
            streak = 1
          end
        end
        prev = token
      end
    end
    #puts "#{my[0]}, #{my[1]}, #{my[2]}"
    #puts "#{opp[0]}, #{opp[1]}, #{opp[2]}"

    h = (5*my[0]) - (10*opp[0])
    h += (3*my[1]) - (6*opp[1])
    h += my[2] - opp[2]
    return h
  end

  def print_board(state)
    state.each do |line|
      puts "#{line[0]}, #{line[1]}, #{line[2]}, #{line[3]}, #{line[4]}, #{line[5]}"
    end
  end

  def parse_board(string)

    board = [[], [], [], [], [], []]
    36.times do |i|
      x = i % 6
      y = (i/6).floor

      board[y][x] = string[i].to_i
    end
    #print_board(board)
    return board
  end

  def stringify_board(board)
    string = ""
    6.times do |i|
      6.times do |j|
        t = board[j][i]
        string += t.to_s
      end
    end
    return string
  end

  def move(state, player, depth)

    actions, states = successor_function(state, player)
    if actions.size > 34
      prng = Random.new
      row = (prng.rand(100) % 2) + 2
      col = (prng.rand(100) % 2) + 2
      while state[row][col] != 0
        row = (prng.rand(100) % 2) + 2
        col = (prng.rand(100) % 2) + 2
      end
      state[row][col] = player
      return state
    end
    max = -1
    imax = -1
    states.each_with_index do |state, i|
      #puts "-----(#{actions[i][0]}, #{actions[i][1]})-------"
      #puts evaluate(state, player)
      r = alphabeta(state, depth, NINF, INF, true, player)
      if r > max
        max = r
        imax = i
      end
    end
    x = actions[imax][0]
    y = actions[imax][1]
    state[x][y] = player
    return state
  end
end


# state =[[ 0,  0,  0,  0,  0,  0],
#       	[ 0,  0,  0,  0,  0,  0],
#       	[ 0,  1,  2,  0,  0,  0],
#       	[ 0,  1,  1,  2,  0,  0],
#       	[ 1,  2,  2,  1,  0,  0],
#       	[ 0,  2,  0,  0,  0,  0]]
# state =[[ 1,  1,  2,  0,  0,  2],
#       	[ 0,  1,  0,  0,  2,  0],
#       	[ 0,  0,  1,  0,  0,  0],
#       	[ 0,  0,  2,  0,  0,  0],
#       	[ 0,  0,  0,  0,  0,  0],
#       	[ 0,  0,  0,  0,  0,  0]]
#
# player = 2
# depth = 2
#
# t = TicTacToe.new
# #string = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
# #puts string.size
# #board = t.parse_board(string)
#
# state = t.move(state, player, depth)
# t.print_board(state)
# #puts t.stringify_board(board)
#puts evaluate(state, player)
#puts alphabeta(state, 2, NINF, INF, true, player)
