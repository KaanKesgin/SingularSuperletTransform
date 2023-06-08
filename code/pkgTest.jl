using PkgTemplates


t = Template(;
           user="KaanKesgin",
           authors=["Kaan Kesgin"],
           plugins=[
               License(name="MIT"),
               Git(),
               GitHubActions(),
           ],
       )


t("SST")
