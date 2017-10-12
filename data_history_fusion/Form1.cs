using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IKHRCDataFusion
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string path = @"C: \Users\InvesdataSystems\Documents\NetBeansProjects\investdata\public_html\alerts\data_history\";
            IEnumerable<string> files = Directory.EnumerateFiles(path);
            List<string> onedataline = new List<string>();

            foreach (string str in files)
            {
                //log(str);

                FileStream fs = new FileStream(str, FileMode.Open);
                StreamReader sr = new StreamReader(fs);
                string oneline = sr.ReadLine();
                //1ere ligne = "Timestamp;Name;Buy;Sell;Spread";
                //détéction du séparateur ; ou ,
                string sep = "";
                bool fileOkForReading = false;
                if (oneline.Contains(";"))
                {
                    sep = ";";
                    fileOkForReading = true;
                }
                else if (oneline.Contains(","))
                {
                    sep = ",";
                    fileOkForReading = true;
                }
                else
                {
                    //MessageBox.Show("Skipping file " + str + " : Separator could not be parsed from line one");
                    fileOkForReading = false;
                }

                //log("Separator detected = '" + sep + "'");

                if (fileOkForReading)
                {
                    while (sr.EndOfStream == false)
                    {
                        string s = sr.ReadLine();
                        onedataline.Add(s);
                    }
                }
                sr.Close();
                fs.Close();
            }

            log(onedataline.Count() + " lines of data read");

            DateTime timestamp = DateTime.Now;
            string ts = timestamp.Year.ToString() + timestamp.Month.ToString("00") + timestamp.Day.ToString("00") + timestamp.Hour.ToString("00") + timestamp.Minute.ToString("00") + timestamp.Second.ToString("00");

            string outputSeparator = ",";

            if (File.Exists(path + @"\" + "ikh-output.csv"))
            {
                File.Delete(path + @"\" + "ikh-output.csv");
            }
            FileStream fso = new FileStream(path + @"\" + ts + "-ikh-output.csv", FileMode.CreateNew);
            StreamWriter sw = new StreamWriter(fso);
            if (outputSeparator == ",")
            {
                sw.WriteLine("Timestamp,Name,Buy,Sell,Spread");
            } else if (outputSeparator == ";")
            {
                sw.WriteLine("Timestamp;Name;Buy;Sell;Spread");
            }
            for (int i = 0; i < onedataline.Count(); i++)
            {
                if ((i>0)&&((i%250000==0)||(i>onedataline.Count()-1)))
                {
                    sw.Close();
                    fso.Close();
                    fso = new FileStream(path + @"\" + ts + "-ikh-output" + i + ".csv", FileMode.CreateNew);
                    sw = new StreamWriter(fso);
                    if (outputSeparator == ",")
                    {
                        sw.WriteLine("Timestamp,Name,Buy,Sell,Spread");
                    }
                    else if (outputSeparator == ";")
                    {
                        sw.WriteLine("Timestamp;Name;Buy;Sell;Spread");
                    }
                }
                string stroutput = "";
                if (outputSeparator == ";")
                {
                    stroutput = onedataline[i].Replace(",", ";");
                }
                else if (outputSeparator == ",")
                {
                    stroutput = onedataline[i].Replace(";", ",");
                }
                sw.WriteLine(stroutput);
            }
            sw.Close();
            fso.Close();
        }

        private void log(string str)
        {
            listBox1.Items.Add(str);
        }
    }
}
