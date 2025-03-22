# frozen_string_literal: true

# Parse2Core モジュールにしてみる
module Parse2Core
  private

  def parse2_core(str)
    str2 =  str
            .gsub(/;.*/, '')
            .gsub('[', '(').gsub(']', ' :q)')
            .gsub('(', '( ').gsub(')', ' )')
            .gsub(/\A/, ' ').gsub(/\z/, ' ')
            .gsub('""', ':s')
    str3 = str2
    str2.scan(/ (".+?") /).each do |expr|
      str3 = str3.gsub(expr[0], "#{expr[0].gsub('"', '').gsub(' ', '%')}:s")
    end
    parse2_sub str3.split(' '), [] # str3.split で文字列から配列へ
  end

  # 配列code1 から 配列code2 へ変換
  def parse2_sub(data, acc)
    case data
    in [] then acc
    in [x, *xs]
      case x
      in '(' then xs2, acc2 = parse2_sub(xs, []); parse2_sub(xs2, acc + [acc2])
      in ')' then [xs, acc]
      else
        case x
        when /\A[-+]?\d+\z/
          parse2_sub xs, acc + [x.to_i] # 数値
        when ':q'
          parse2_sub xs, acc + [:q]     # リストのしるし
        when 'true'
          parse2_sub xs, acc + [true]
        when 'false'
          parse2_sub xs, acc + [false]
        else
          parse2_sub xs, acc + [x]
        end
      end
    end
  end

  def run_after(code, str = code.to_s)
    str2 = str.gsub(/ ?:q/, '').gsub(',', '').gsub('%', ' ')
    if /"/ !~ str2 && /:s/ =~ str2
      str2.gsub(':s', '').gsub(/(.+)/, '"\1"') # 単独文字列
    else
      str2.gsub(':s', '')                      # リスト
    end
  end
end
