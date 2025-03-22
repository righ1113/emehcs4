# frozen_string_literal: true

# ・実行方法
# $ cd emehcs4
# $ ruby test/emehcs_test.rb

require 'minitest/autorun'
require './emehcs'

class EmehcsTest < Minitest::Test
  def test_case1
    emehcs = Emehcs.new
    code1  = '1 2 + ` `'
    code2  = '3 7 + ` ` 1 + ` `'
    code3  = '2 3 7 + ` ` + ` `'
    code4  = '99 =x x'
    code5  = '(=x (1 8 + ` `)) >fact 4 fact `'
    code6  = '(=x x) >id (5 1 - ` `) id `'
    code7  = '(=x (1 x + ` `)) >id 4 id `'
    # code8  = '(=x ((x 1 - ` `) fact ` ` x * ` `) 1 (x 2 < ` `) ?) >fact 4 fact `'
    code8  = '(=x ((x 1 - ` `) fact ` x * ` `) 1 true ?) >fact 4 fact `' # カッコ部は遅延評価
    code9  = '(=ret =x ((x 1 - ` `) (ret x * ` `) fact ~ `) ret (x 2 < ` `) ?) >fact 4 1 fact ~ `'
    code10 = '5 1 fact ~ `'
    # code11 = [[1, 2, 3, :q], 'id']
    # code12 = [[1, 2, 3, :q], '=dat', 'dat', 'id']

    assert_equal '3',   (emehcs.run code1)
    assert_equal '11',  (emehcs.run code2)
    assert_equal '12',  (emehcs.run code3)
    assert_equal '99',  (emehcs.run code4)
    assert_equal '9',   (emehcs.run code5)
    assert_equal '4',   (emehcs.run code6)
    assert_equal '5',   (emehcs.run code7)
    assert_equal '1',   (emehcs.run code8)
    assert_equal '24',  (emehcs.run code9)
    assert_equal '120', (emehcs.run code10)
    # assert_equal [1, 2, 3, :q],        (emehcs.parse_run code11)
    # assert_equal [1, 2, 3, :q],        (emehcs.parse_run code12)
  end

  # def test_case2
  #   emehcs = Emehcs.new
  #   code22 = '[] [3] =='
  #   code24 = '5 (5 +) (2 *)'
  #   code25 = '((4 3 false ?) 2 false ?) 1 false ?'
  #   code26 = '5 (5 +) (2 *) (3 -)'
  #   code27 = '"aaa    aaa a   a"'

  #   assert_equal 'false',              (emehcs.run code22)
  #   assert_equal '20',                 (emehcs.run code24)
  #   assert_equal '4',                  (emehcs.run code25)
  #   assert_equal '17',                 (emehcs.run code26)
  #   assert_equal '"aaa    aaa a   a"', (emehcs.run code27)
  # end

  # def test_case3
  #   emehcs = Emehcs.new
  #   code34 = '"abcde" 2 !!'
  #   code35 = '"abcde" length'
  #   code36 = '88 chr'
  #   code37 = '[1 2 3] 1 100 up_p'
  #   code38 = '0 99 ((3 3 ==) true &&) ?'
  #   code39 = '7 (>x x) (>x x)'

  #   assert_equal '"c"',                (emehcs.run code34)
  #   assert_equal '5',                  (emehcs.run code35)
  #   assert_equal 'X',                  (emehcs.run code36)
  #   assert_equal '[1 102 3]',          (emehcs.run code37)
  #   assert_equal '99',                 (emehcs.run code38)
  #   assert_equal '7',                  (emehcs.run code39)
  # end
end
