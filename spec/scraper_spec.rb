# encoding: UTF-8

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

  context "Begin" do
    Given(:input) { [] }
    Then { output.should == "" }

    context "> Title" do
      When {
        input << <<-html
<h2 align="center">CONSTITUCION DE LA REPUBLICA</h2>
        html
      }
      Then {
        output.should end_with <<-md
CONSTITUCION DE LA REPUBLICA
============================
        md
      }

      context "> Subtitle" do
        When {
          input << <<-html
<h4 align="center">CONSTITUCION 1967 CON LAS MODIFICACIONES PLEBISCITADAS EL 26 DE
NOVIEMBRE DE 1989, EL 26 DE NOVIEMBRE DE 1994 Y EL 8 DE DICIEMBRE DE 1996</h4>
          html
        }
        Then {
          output.should end_with <<-md
CONSTITUCION 1967 CON LAS MODIFICACIONES PLEBISCITADAS EL 26 DE NOVIEMBRE DE 1989, EL 26 DE NOVIEMBRE DE 1994 Y EL 8 DE DICIEMBRE DE 1996
          md
        }

        context "> Section" do
          When {
            input << <<-html
<h4 align="center">SECCION I</h4>
            html
          }
          Then {
            output.should end_with <<-md

## SECCION I
            md
          }

          context "> Section subtitle" do
            When {
              input << <<-html
<h4 align="center">DE LA NACION Y SU SOBERANIA</h4>
              html
            }
            Then {
              output.should end_with <<-md
DE LA NACION Y SU SOBERANIA
              md
            }

            context "> Chapter" do
              When {
                input << <<-html
<h4 align="center">CAPITULO I</h4>
                html
              }
              Then {
                output.should end_with <<-md

### CAPITULO I
                md
              }

              context "> Article" do
                When {
                  input << <<-html
<p><u><a name="art1">Artículo 1º</a></u>.- Lorem ipsum</p>
                  html
                }
                Then {
                  output.should end_with <<-md
__Artículo 1__. Lorem ipsum
                  md
                }
                context "followed by articles" do
                  When {
                    input << <<-html
<p><u><a name="art2">Artículo 2</a></u>.- Lorem ipsum.</p>
                    html
                  }
                  Then {
                    output.should end_with <<-md

__Artículo 2__. Lorem ipsum.
                    md
                  }
                end

                context "with aditional paragraphs" do
                  When {
                    input << <<-html
<p>Lorem ipsum</p>
                    html
                  }
                  Then {
                    output.should end_with <<-md

Lorem ipsum
                    md
                  }
                end

                context "with items in a TABLE" do
                  When {
                    input << <<-html
<table>
  <tr>
    <td>A)</td>
    <td>Lorem ipsum</td>
  </tr>
  <tr>
    <td>B)</td>
    <td>Lorem ipsum</td>
  </tr>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md

A) Lorem ipsum

B) Lorem ipsum
                    md
                  }
                end

                context "with items in a TABLE with TBODY" do
                  When {
                    input << <<-html
<table>
  <tbody>
    <tr>
      <td>A)</td>
      <td>Lorem ipsum</td>
    </tr>
  </tbody>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md

A) Lorem ipsum
                    md
                  }
                end

                context "with items enumerated with primes" do
                  When {
                    input << <<-html
<table>
  <tr>
    <td>A')</td>
    <td>Lorem ipsum</td>
  </tr>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md

A') Lorem ipsum
                    md
                  }
                end

                context "with items and subitems" do
                  When {
                    input << <<-html
<table>
  <tr>
    <td>A)</td>
    <td>Lorem ipsum</td>
  </tr>
  <tr>
    <td></td>
    <td>a)</td>
    <td>Lorem ipsum</td>
  </tr>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md

A) Lorem ipsum

a) Lorem ipsum
                    md
                  }
                end

                context "with just subitems" do
                  When {
                    input << <<-html
<table>
  <tr>
    <td></td>
    <td>a)</td>
    <td>Lorem ipsum</td>
  </tr>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md

a) Lorem ipsum
                    md
                  }
                end

                context "with items spanning many paragraphs" do
                  When {
                    input << <<-html
<table>
  <tr>
    <td>A)</td>
    <td>Lorem ipsum</td>
  </tr>
  <tr>
    <td></td>
    <td>Lorem ipsum</td>
  </tr>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md

A) Lorem ipsum

Lorem ipsum
                    md
                  }
                end

                context "with items and subitems in rows containing blank columns" do
                  When {
                    input << <<-html
<table>
  <tr>
    <td>A)</td>
    <td></td>
    <td>Lorem ipsum</td>
  </tr>
  <tr>
    <td></td>
    <td></td>
    <td>a)</td>
    <td>Lorem ipsum</td>
  </tr>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md

A) Lorem ipsum

a) Lorem ipsum
                    md
                  }
                end

                context "with items in rows containing special references" do
                  When {
                    input << <<-html
<table>
  <tr>
    <td>A)</td>
    <td><a>*</a></td>
    <td>Lorem ipsum</td>
  </tr>
  <tr>
    <td>B)</td>
    <td><a>***</a></td>
    <td>Lorem ipsum</td>
  </tr>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md

A) * Lorem ipsum

B) *** Lorem ipsum
                    md
                  }
                end

                context "with items containing line breaks" do
                  When {
                    input << <<-html
<table>
  <tr>
    <td>A)</td>
    <td>Lorem
    ipsum</td>
  </tr>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md
A) Lorem ipsum
                    md
                  }
                end

                context "with items having different index separators" do
                  When {
                    input << <<-html
<table>
  <tr>
    <td>A.</td>
    <td>Lorem ipsum</td>
  </tr>
  <tr>
    <td>1º</td>
    <td>Lorem ipsum</td>
  </tr>
  <tr>
    <td>21.-</td>
    <td>Lorem ipsum</td>
  </tr>
  <tr>
    <td>Z')</td>
    <td>Lorem ipsum</td>
  </tr>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md
A) Lorem ipsum

1) Lorem ipsum

21) Lorem ipsum

Z') Lorem ipsum
                    md
                  }
                end
              end

              context "> Article with ordinal indicator" do
                When {
                  input << <<-html
<p><u><a name="art1">Artículo 1º</a></u>.- Lorem ipsum.</p>
                  html
                }
                Then {
                  output.should end_with <<-md
__Artículo 1__. Lorem ipsum.
                  md
                }
              end

              context "> Article with line breaks" do
                When {
                  input << <<-html
<p><u><a>Artículo 1</a></u>.- Lorem
ipsum</p>
                  html
                }
                Then {
                  output.should end_with <<-md
__Artículo 1__. Lorem ipsum
                  md
                }
              end

              context "> Article with BR tags" do
                When {
                  input << <<-html
<p><u><a>Artículo 1</a></u>.- Lorem<br> ipsum</p>
                  html
                }
                Then {
                  output.should end_with <<-md
__Artículo 1__. Lorem ipsum
                  md
                }
              end

              context "> Article with underline inside anchor" do
                When {
                  input << <<-html
<p><a name="art1"><u>Artículo 1º</u></a>.- Lorem ipsum</p>
                  html
                }
                Then {
                  output.should end_with <<-md
__Artículo 1__. Lorem ipsum
                  md
                }
              end

              context "> Transitional arrangements" do
                When {
                  input << <<-html
<h4>DISPOSICIONES TRANSITORIAS</h4>
                  html
                }
                Then {
                  output.should end_with <<-md

## DISPOSICIONES TRANSITORIAS
                  md
                }

                context "> With items in a TABLE" do
                  When {
                    input << <<-html
<table>
  <tbody>
    <tr>
      <td>A)</td>
      <td>Lorem ipsum</td>
    </tr>
  </tbody>
</table>
                    html
                  }
                  Then {
                    output.should end_with <<-md
A) Lorem ipsum
                    md
                  }

                  context "> With endnotes" do
                    When {
                      input << <<-html
<hr>
<div>
  <table>
    <tbody>
      <tr>
        <td>*</td>
        <td>Lorem ipsum</td>
      </tr>
      <tr>
        <td>**</td>
        <td>Lorem ipsum</td>
      </tr>
    </tbody>
  </table>
</div>
                      html
                    }
                    Then {
                      output.should end_with <<-md
A) Lorem ipsum

---

(*) Lorem ipsum

(**) Lorem ipsum
                      md
                    }

                    context "> With tags after endnotes" do
                      When {
                        input << <<-html
<div>
  <table><tr><td>1</td></tr></table>
</div>
                        html
                      }
                      Then {
                        output.should end_with <<-md
(**) Lorem ipsum
                        md
                      }
                    end
                  end
                end

                context "> With parts" do
                  When {
                    input << <<-html
<h4>IV</h4>
                    html
                  }
                  Then {
                    output.should end_with <<-md
### IV
                    md
                  }
                end
              end
            end

            context "> Unique chapter" do
              When {
                input << <<-html
<h4>CAPITULO UNICO</h4>
                html
              }
              Then {
                output.should end_with <<-md
### CAPITULO UNICO
                md
              }
            end
          end

          context "> Section subtitle in multiple lines" do
            When {
              input << <<-html
<h4>Lorem ipsum</h4>
<h4>Lorem ipsum</h4>
              html
            }
            Then {
              output.should end_with <<-md
Lorem ipsum

Lorem ipsum
              md
            }
          end
        end
      end
    end

    context "> Document with strange tags" do
      When {
        input << <<-html
<div>Should be avoided</div>
<h2 align="center">Main Title</h2>
<div>Should be avoided</div>
<div>Should be avoided</div>
<h4>Main Subtitle</h4>
<div>Should be avoided</div>
<p>Also Main Subtitle</p>
<div>Should be avoided</div>
<h4>Sección 1</h4>
<div>Should be avoided</div>
<h4>Capítulo 1</h4>
        html
      }
      Then {
        output.should end_with <<-md
Main Title
==========

Main Subtitle

Also Main Subtitle

## Sección 1

### Capítulo 1
        md
      }
    end
  end
end
