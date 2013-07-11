require "spec_helper"

describe Parceira::Reader do

  describe :process! do
    describe "using default headers" do
      let(:path) { File.expand_path('./../../../tmp/contacts-us-ascii.csv', __FILE__) }
      let(:expected) {
        [
          {:first_name=>"Marcos", :last_name=>"Zimmermann"},
          {:first_name=>"Paul", :last_name=>"Molive"},
          {:first_name=>"Maya", :last_name=>"Didas"}
        ]
      }

      context "from string" do
        subject { Parceira::Reader.new(File.read(path), {}).process! }
        it { should eq(expected)}
      end

      context "from file" do
        subject { Parceira::Reader.new(path, {}).process! }
        it { should eq(expected)}
      end
    end

    describe "disable headers" do
      let(:path) { File.expand_path('./../../../tmp/contacts-us-ascii.csv', __FILE__) }
      let(:options) { {headers: false} }
      let(:expected) {
        [
          ["Marcos", "Zimmermann"],
          ["Paul", "Molive"],
          ["Maya", "Didas"]
        ]
      }

      context "from string" do
        subject { Parceira::Reader.new(File.read(path), options).process! }
        it { should eq(expected)}
      end

      context "from file" do
        subject { Parceira::Reader.new(path, options).process! }
        it { should eq(expected)}
      end
    end

    describe "overwriting headers" do
      let(:path) { File.expand_path('./../../../tmp/contacts-us-ascii.csv', __FILE__) }
      let(:options) { {headers: ['First Name', 'Middle Name']} }
      let(:expected) {
        [
          {'First Name'=>"Marcos", 'Middle Name'=>"Zimmermann"},
          {'First Name'=>"Paul", 'Middle Name'=>"Molive"},
          {'First Name'=>"Maya", 'Middle Name'=>"Didas"}
        ]
      }

      context "from string" do
        subject { Parceira::Reader.new(File.read(path), options).process! }
        it { should eq(expected)}
      end

      context "from file" do
        subject { Parceira::Reader.new(path, options).process! }
        it { should eq(expected)}
      end
    end

    describe "include first row(Header)" do
      let(:path) { File.expand_path('./../../../tmp/contacts-us-ascii.csv', __FILE__) }
      let(:options) { {headers_included: false, headers: false} }
      let(:expected) {
        [
          ["First Name", "Last Name"],
          ["Marcos", "Zimmermann"],
          ["Paul", "Molive"],
          ["Maya", "Didas"]
        ]
      }

      context "from string" do
        subject { Parceira::Reader.new(File.read(path), options).process! }
        it { should eq(expected)}
      end

      context "from file" do
        subject { Parceira::Reader.new(path, options).process! }
        it { should eq(expected)}
      end
    end
  end


  describe :convert_to_hash do
    let(:header) { [:foo, :bar] }
    context "reject nil values" do
      let(:values) { ["Foo", nil] }
      subject { Parceira::Reader.new('', {reject_nil: true}).send(:convert_to_hash, header, values) }
      it { should eq({foo:"Foo"})}
    end

    context "allow nil values" do
      let(:values) { ["Foo", nil] }
      subject { Parceira::Reader.new('', {reject_nil: false}).send(:convert_to_hash, header, values) }
      it { should eq({foo:"Foo",bar:nil})}
    end
  end


  describe :parse_values do
    it "should strip values" do
      expect(Parceira::Reader.new('', {reject_blank: false}).send(:parse_values, ['Foo ', nil, ' Bar', ' ', 'Age'])).to eq(["Foo", "", "Bar", "", "Age"])
    end

    describe "convert_to_numeric true" do
      subject { Parceira::Reader.new('', {convert_to_numeric: true}).send(:parse_values, values) }
      context "Fixnum" do
        let(:values) { ['Foo', '1', 'Bar'] }
        it { should eq(["Foo", 1, "Bar"])}
      end

      context "Negative Fixnum" do
        let(:values) { ['Foo', '-1', 'Bar'] }
        it { should eq(["Foo", -1, "Bar"])}
      end

      context "Positive Fixnum" do
        let(:values) { ['Foo', '+1', 'Bar'] }
        it { should eq(["Foo", 1, "Bar"])}
      end

      context "Float" do
        let(:values) { ['Foo', '1.23', 'Bar'] }
        it { should eq(["Foo", 1.23, "Bar"])}
      end

      context "Negative Float" do
        let(:values) { ['Foo', '-1.23', 'Bar'] }
        it { should eq(["Foo", -1.23, "Bar"])}
      end

      context "Positive Float" do
        let(:values) { ['Foo', '+1.23', 'Bar'] }
        it { should eq(["Foo", 1.23, "Bar"])}
      end
    end

    describe "reject_blank" do
      context "true" do
        subject { Parceira::Reader.new('', {reject_blank: true}).send(:parse_values, ['Foo', '', 'Bar']) }
        it { should eq(["Foo", nil, "Bar"])}
      end

      context "false" do
        subject { Parceira::Reader.new('', {reject_blank: false}).send(:parse_values, ['Foo', '', 'Bar']) }
        it { should eq(["Foo", '', "Bar"])}
      end
    end

    describe "reject_zero" do
      context "true" do
        subject { Parceira::Reader.new('', {reject_zero: true}).send(:parse_values, ['Foo', '0', 'Bar', '0.0']) }
        it { should eq(["Foo", nil, "Bar", nil])}
      end
      context "false" do
        subject { Parceira::Reader.new('', {reject_zero: false}).send(:parse_values, ['Foo', '0', 'Bar', '0.0']) }
        it { should eq(["Foo", 0, "Bar", 0.0])}
      end
    end

    describe "reject_matching" do
      context "match with /^B/" do
        subject { Parceira::Reader.new('', {reject_matching: /^B/}).send(:parse_values, ['Foo', 'Bar']) }
        it { should eq(["Foo", nil])}
      end
      context "nil" do
        subject { Parceira::Reader.new('', {reject_matching: nil}).send(:parse_values, ['Foo', 'Bar']) }
        it { should eq(["Foo", "Bar"])}
      end
    end
  end

  describe :parse_header do
    subject { Parceira::Reader.new('', {}).send(:parse_header, values) }
    context "with whitespace character" do
      let(:values) { ['First Name', 'Last Name', 'Age']}
      it { should eq([:first_name, :last_name, :age])}
    end

    context "one missing key" do
      let(:values) { ['First Name', nil, 'Age']}
      it { should eq([:first_name, :field_2, :age])}
    end

    context "missing values" do
      let(:values) { ['', nil, '']}
      it { should eq([:field_1, :field_2, :field_3])}
    end

  end

  describe :process! do

  end

  describe :input_file do
    let(:path) { File.expand_path('./../../../tmp/contacts-us-ascii.csv', __FILE__) }
    it { expect(File.exists?(path)).to be_true }

    context "intance of File" do
      let(:file) { File.open(path) }
      subject { Parceira::Reader.new(file, {}).send(:input_file) }
      it { should eq(file)}
    end

    context "filename" do
      let(:file) { double('File') }
      before(:each) do
        File.should_receive(:open).with(path, 'r:us-ascii').and_return(file)
      end
      subject { Parceira::Reader.new(path, {}).send(:input_file) }
      it { should eq(file)}
    end

    context "csv string" do
      subject { Parceira::Reader.new('foo,bar', {}).send(:input_file) }
      it { should be_nil}
    end
  end


  describe :charset do
    let(:path) { File.expand_path('./../../../tmp/contacts-us-ascii.csv', __FILE__) }
    it { expect(File.exists?(path)).to be_true }

    context ":file_encoding config" do
      subject { Parceira::Reader.new(path, {file_encoding: 'iso-8859-1'}).send(:charset) }
      it { should eq('iso-8859-1')}
    end

    context "instance of File" do
      subject { Parceira::Reader.new(File.open(path), {}).send(:charset) }
      it { should eq('us-ascii')}
    end

    context "filename" do
      subject { Parceira::Reader.new(path, {}).send(:charset) }
      it { should eq('us-ascii')}
    end

    context "csv string" do
      subject { Parceira::Reader.new("name,age\nFoo Bar,25", {}).send(:charset) }
      it "returns default_charset value" do
        should eq('utf-8')
      end
    end
  end


  describe :csv_options do
    subject { Parceira::Reader.new('', {}).send(:csv_options) }
    it "includes only options allowed on CSV.parse method" do
      should have_key(:col_sep)
      should have_key(:row_sep)
      should have_key(:quote_char)
      should_not have_key(:headers)
      should_not have_key(:reject_blank)
      should_not have_key(:reject_nil)
      should_not have_key(:reject_matching)
      should_not have_key(:convert_to_numeric)
    end
  end


  describe :default_charset do
    subject { Parceira::Reader.new('/tmp/path', {}).send(:default_charset) }
    it { should eq('utf-8')}
  end


  it { expect(Parceira::Reader).to be_const_defined('DEFAULT_OPTIONS') }
end
