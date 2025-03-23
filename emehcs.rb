# frozen_string_literal: true

# ＜以下は1回だけおこなう＞
# rbenv で Ruby 3.3.5(じゃなくてもいい) を入れる
# $ gem install bundler
# $ cd emehcs4
# $ bundle install --path=vendor/bundle
# ＜実行方法＞
# $ cd emehcs4
# $ RUBY_THREAD_VM_STACK_SIZE=100000000 bundle exec ruby emehcs.rb
# > [Ctrl+D] か exit で終了
require './lib/const'
require './lib/parse2_core'
require './lib/repl'

# EmehcsBase クラス
class EmehcsBase
  include Const
  private def initialize = (@env = {}; @stack = [])
  private def common(count, values = init_common(count))
    values.map! { |y| func?(y) ? parse_run(y) : y } # スタックから count 個の要素を取り出して評価する(実際に値を使用する前段階)
    count == 1 ? values.first : values              # count が 1 なら最初の要素を返す
  end
  private def my_if_and(count = 3, values = init_common(count))
    else_c = Delay.new { count == 3 ? (p 'gyaaaa'; parse_run([values[2]])) : false }
    parse_run([values[0]]) ? parse_run([values[1]]) : else_c.force
  end
  private def apply(c)
    puts "(1) f:#{@stack[-1]}, x:#{@stack[-2]}"
    f = pop_raise
    if EMEHCS_FUNC_TABLE.key? f
      x = parse_run([pop_raise])
      EMEHCS_FUNC_TABLE[f][x]
    elsif f.is_a?(Proc)
      puts "(2) f:#{f}, x:#{@stack[-1]}"
      x = parse_run([pop_raise])
      f[x]
    elsif f.is_a?(Array) then apply_sub f, c
    elsif @env[f].is_a?(Array) then apply_sub @env[f], c
    end
  end
  private def apply_sub(f, c)
    if c == '~'
      puts "(3) f:#{f}, x:#{@stack[-1]}"
      x = parse_run([pop_raise])
      [x] + f
    else
      parse_array f, true # 実行する
    end
  end
end

# Emehcs クラス 相互に呼び合っているから、継承
class Emehcs < EmehcsBase
  include Parse2Core
  public def run(str_code) = (@stack = []; run_after parse_run parse2_core str_code)
  private def parse_run(code)
    case code # メインルーチン、code は Array
    in [] then @stack.pop
    in [x, *xs]
      case x
      in Integer | TrueClass | FalseClass | Proc then @stack.push x
      in Array                            then @stack.push parse_array  x, xs.empty?
      in String                           then my_ack_push parse_string x, xs.empty?
      in Symbol                           then nil # do nothing
      else                                raise ERROR_MESSAGES[:unexpected_type]
      end; parse_run xs
    end
  end
  private def parse_array(x, em) = em && func?(x) ? parse_run(x) : x
  private def parse_string(x, em, name = x[1..], _db = [x, @env[x]], co = Const.deep_copy(@env[x]))
    # db.each { |y| (em ? send(EMEHCS_FUNC_TABLE[y]) : @stack.push(y); return nil) if EMEHCS_FUNC_TABLE.key? y }
    if    ['`', '~'].include?(x) then apply x
    elsif x == '?' then my_if_and
    elsif x[-2..] == SPECIAL_STRING_SUFFIX then x # 純粋文字列 :s
    elsif    x[0] == FUNCTION_DEF_PREFIX # 関数束縛
      @env[name] = parse_array(pop_raise, false)
      em_n_nil(em, name)
    elsif    x[0] == VARIABLE_DEF_PREFIX
      @env[name] = parse_array(pop_raise, true)
      em_n_nil(em, name)
    elsif  @env[x].is_a?(Array) then parse_array co, em # code の最後かつ関数なら実行する
    elsif !@env[x].nil? then @env[x] # x が変数名
    elsif EMEHCS_FUNC_TABLE.key? x then EMEHCS_FUNC_TABLE[x]
    else
      x
    end
  end
end
Repl.new(Emehcs.new).prelude.repl if __FILE__ == $PROGRAM_NAME # メイン関数としたもの
