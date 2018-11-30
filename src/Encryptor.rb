class Integer
  N_BYTES = [42].pack('i').size
  N_BITS = N_BYTES * 16
  MAX = 2 ** (N_BITS - 2) - 1
  MIN = -MAX - 1
end

class Encryptor

  def n
    @n
  end

  def e
    @e
  end

  def d
    @d
  end

  def key_generation(p, q)

    # Compute n = pq.
    @n = p * q

    # Compute λ(n) = lcm(λ(p), λ(q)) = lcm(p − 1, q − 1),
    # where λ is Carmichael's totient function.
    lambda_n = lambda(p, q)

    # Choose an integer e such that 1 < e < λ(n) and gcd(e, λ(n)) = 1.
    @e = 65537
    while(gcd(@e, lambda_n) != 1 && @e < lambda_n)
      e += 1
    end

    # Determine d as d ≡ e−1 (mod λ(n))
    # i.e., d is the modular multiplicative inverse of e modulo λ(n).
    @d = modular_linear_equation(@e, 1, lambda_n, 1)
  end

  # c(m) = m^e mod n
  def encrypt(m)
    #puts "#{m} ^ #{e} mod #{n}"
    modular_exponentiation(m, @e, @n)
  end

  # m = c^d mod n
  def decrypt(c)
    #puts "#{c} ^ #{d} mod #{n}"
    modular_exponentiation(c, @d, @n)
  end

  # true if n is pseudoprime, checks k times
  def primality_test(n, k)
    prng = Random.new
    # Repeat k times:
    k.times do |i|
      # Pick a random int in the range [2, n − 2]
      a = prng.rand(n - 4) + 2
      # If a^(n-1) = 1 (mod n), then return composite
      a = modular_exponentiation(a, n-1, n)
      if !a.nil? and !congruence_mod(a, 1, n)
        return false
      end
    end
    # If composite is never returned: return probably prime
    return true
  end

  # a x == b (mod n) returns x
  def modular_linear_equation(a, b, n, x_n)
    d, x, y = extended_euclid(a, n)
    # if d | b
    if(mod(b, d) == 0)
      x_naught = x * mod(div(b, d), n)
      x_naught += x_n * div(n, d)
      return mod(x_naught, n)
    else
      return nil
    end
  end

  # computes a ^ b (mod n)
  def modular_exponentiation(a, b, n)
    c = 0
    d = 1
    k = b.to_s(2).size # Where n is number of bits in N
    (k).downto(0) do |i|
      c << 1
      d = mod((d * d), n)
      if query_nth_bit(b, i) == 1
        c += 1
        d = mod((d * a), n)
      end
    end
    return d
  end

  # evaluates a === b (mod n)
  def congruence_mod(a, b, n)
    # due to symmetry, could be either direction
    if a > b
      dif = a - b
    elsif a < b
      dif = b - a
    else
      return true
    end

    if n > dif
      c = mod(n,dif)
    else
      c = mod(dif, n)
    end

    # n|b-a
    if c == 0
      return true
    else
      return false
    end
  end

  # d = gcd(a, b) = ax + by
  # returns d, x, y
  def extended_euclid(a, b)
    if b == 0
      return a, 1, 0
    else
      d, x, y = extended_euclid(b, mod(a,b))
      #puts "gcd(#{a}, #{b}) = #{d} = #{a} * #{x} + #{b} * #{y}"
      w = div(a, b)
      return d, y, x - (w * y)
    end
  end

  # Carmichael's totient function lambda(n) = lambda(p, q) where n = pq
  def lambda(p, q)
    lcm(p - 1, q - 1)
  end

  # returns #{x} where gcd(x, n) = 1 and x < n
  def euler_phi(n)
  	count = 0
  	(n+1).times do |i|
  		if 1 == gcd(n, i)
        count += 1
      end
  	end
  	return count
  end

  # greatest common divisor
  def gcd(a, b)
    d, x, y = extended_euclid(a, b)
    return d
  end

  # least common multiple
  def lcm(a, b)
    d = gcd(a, b)
    div((a * b),d)
  end

  # binary long division
  # returns q, r
  def bld(n, d)
    if d == 0
      return nil
    end
    q = 0 # Initialize quotient and remainder to zero
    r = 0
    k = n.to_s(2).size # Where n is number of bits in N
    (k - 1).downto(0) do |i|
      r <<= 1 # Left-shift R by 1 bit
      # Set the least-significant bit of R equal to bit i of the numerator
      r = change_nth_bit(r,0, query_nth_bit(n, i))
      if r >= d
        r -= d
        q = change_nth_bit(q, i, 1)
      end
    end
    return q, r
  end

  # a  = q b + r
  # r =  a -  q b
  # q  = (a - r) / b
  def mod(a, b)
    q, r = bld(abs(a), abs(b))
    if sign(b)
      return r
    else
      return -r
    end
  end

  # signed, a / b
  def div(a, b)
    q, r = bld(abs(a), abs(b))
    if sign(a) == sign(b)
      return q
    else
      return -q
    end
  end

  # greatest integer not exceeding n
  # returns floor(n) < n < n + 1
  def floor(n)
    n - mod(n, 1)
  end

  # distance function
  def abs(n)
    if n >= 0
      return n
    else
      return -n
    end
  end

  # 1 if postive or 0
  # 0 if negative
  def sign(n)
    if n >= 0
      return 1
    else
      return 0
    end
  end

  def set_nth_bit(number, n)
    number |= 1 << n
  end

  def clear_nth_bit(number, n)
    number &= ~(1 << n)
  end

  def toggle_nth_bit(number, n)
    number ^= 1 << n
  end

  def query_nth_bit(number, n)
    (number >> n) & 1
  end

  def change_nth_bit(number, n, x)
    number ^= (-x ^ number) & (1 << n)
  end

end

# e = Encryptor.new
# p = 10006660007
# q = 8675309
# m = 123456789
# if e.primality_test(p, 50)
#   if e.primality_test(q, 50)
#     e.key_generation(p, q)
#     puts e.n
#     puts e.d
#     puts e.e
#     puts "C following"
#     puts c = e.encrypt(m)
#     puts "t following"
#     puts t = e.decrypt(c)
#   end
# else
#   puts "These are not prime numbers"
# end

#puts e.mod(-100, 8)

# (a/b) * b + a%b = a
# r = a - q(b)


#
# # 100 = 12(8) + 4
# # 12 * 8 + 4 = 100
# puts 100 % 8 # 4
# puts e.div(100, 8) # 12
#
#
# # -100 = -12(8) + 4
# # -12 * 8 + 4 = -100
# puts -100 % 8 # 4
# puts e.div(-100, 8) # -12
#
#
# # -100 = 12(-8) - 4
# # 12 * -8 - 4 = -100
# puts -100 % -8 # -4
# puts e.div(-100, -8) #12
#
#
# # 100 = -12(-8) + 4
# # 12 * 8 + 4 = 100
# puts 100 % -8 # -4
# puts e.div(100, -8) # -12





# a = 46
# b = 240
# d, x, y = e.extended_euclid(b, e.mod(a,b))
# puts "gcd(#{a}, #{b}) = #{d} = #{a} * #{x} + #{b} * #{y}"
# a = 14
# b = 30
# n = 100
# puts e.modular_linear_equation(a, b, n, 0)

#puts e.div(100, 50)
