require 'rspec/given'
require 'scraper'

describe Scraper do
  def output
    html = <<-html
      <html>
        <head></head>
        <body>
        #{input.join("")}
        </body>
      </html>
    html
    Scraper.new(html).to_markdown
  end

  context "with no contents" do
    Given(:input) { [] }
    Then { output.should == "" }

    context "receiving title" do
      When {
        input << <<-html
          <h2 align="center">CONSTITUCION DE LA REPUBLICA</h2>
        html
      }
      Then {
        output.should end_with <<-md.gsub(/^ +/, '')
          CONSTITUCION DE LA REPUBLICA
          ============================
        md
      }

      context "receiving subtitle" do
        When {
          input << <<-html
            <h4 align="center">CONSTITUCION 1967 CON LAS MODIFICACIONES PLEBISCITADAS EL 26 DE
            NOVIEMBRE DE 1989, EL 26 DE NOVIEMBRE DE 1994 Y EL 8 DE DICIEMBRE DE 1996</h4>
          html
        }
        Then {
          output.should end_with <<-md.gsub(/^ +/, '')
            CONSTITUCION 1967 CON LAS MODIFICACIONES PLEBISCITADAS EL 26 DE NOVIEMBRE DE 1989, EL 26 DE NOVIEMBRE DE 1994 Y EL 8 DE DICIEMBRE DE 1996
          md
        }
      end
    end
  end
end
