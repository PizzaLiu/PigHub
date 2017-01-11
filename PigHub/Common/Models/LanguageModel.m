//
//  LanguagesModel.m
//  PigHub
//
//  Created by Rainbow on 2016/12/31.
//  Copyright © 2016年 PizzaLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageModel.h"

#pragma mark - Language

@interface Language()

@end

@implementation Language

- initWithName:(NSString *)name query:(NSString *)query
{
    self = [self init];

    self.name = name;
    self.query = query;

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.query forKey:@"query"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.query = [aDecoder decodeObjectForKey:@"query"];

    return self;
}

@end

#pragma mark - LanguageModel

@interface LanguagesModel()

@property(nonatomic, strong)NSMutableArray *languages;

@end

@implementation LanguagesModel

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[LanguagesStorage sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];

    self.languages = [self getAllLanguages];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(saveLanguages) name:UIApplicationDidEnterBackgroundNotification object:nil];

    return self;
}

+ (instancetype)sharedStore
{
    static LanguagesModel *sharedStore = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });

    return sharedStore;
}

#pragma makr - languages

- (NSString *) languageNameForIndex:(NSInteger) index
{
    Language *language = self.languages[index];
    if (!language) return @"";
    return language.name;
}

- (Language *) languageForIndex:(NSInteger) index
{
    Language *language = self.languages[index];
    return language;
}

- (Language *) languageForName:(NSString *) name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *filteredArray = [self.languages filteredArrayUsingPredicate:predicate];

    if (filteredArray) {
        return filteredArray[0];
    }
    return nil;
}

- (Language *) languageForQuery:(NSString *) query
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"query == %@", query];
    NSArray *filteredArray = [self.languages filteredArrayUsingPredicate:predicate];

    if (filteredArray) {
        return filteredArray[0];
    }
    return nil;
}

- (NSArray *) allLanguages
{
    return self.languages;
}

- (NSInteger) languagesCount
{
    return [self.languages count];
}

- (void) moveLanguageAtIndex:(NSInteger) fromIndex toIndex:(NSInteger) toIndex
{
    if (fromIndex == toIndex) {
        return;
    }

    Language *language = [self.languages objectAtIndex:fromIndex];
    [self.languages removeObjectAtIndex:fromIndex];
    [self.languages insertObject:language atIndex:toIndex];
}

- (Language *) genLanguageWithName:(NSString *)name query:(NSString *)query
{
    return [[Language alloc] initWithName:name query:query];
}

- (NSMutableArray *) getAllLanguages
{
    NSMutableArray *languages = [self readLanguages];

    if (languages) {
        return languages;
    }

    languages = [[NSMutableArray alloc] init];

    [languages addObject:[self genLanguageWithName:@"All Languages" query:@""]];

    [languages addObject:[self genLanguageWithName: @"JavaScript" query: @"javascript"]];
    [languages addObject:[self genLanguageWithName: @"Java" query: @"java"]];
    [languages addObject:[self genLanguageWithName: @"Python" query: @"python"]];
    [languages addObject:[self genLanguageWithName: @"CSS" query: @"css"]];
    [languages addObject:[self genLanguageWithName: @"PHP" query: @"php"]];
    [languages addObject:[self genLanguageWithName: @"Ruby" query: @"ruby"]];
    [languages addObject:[self genLanguageWithName: @"C++" query: @"cpp"]];
    [languages addObject:[self genLanguageWithName: @"C" query: @"c"]];
    [languages addObject:[self genLanguageWithName: @"Shell" query: @"bash"]];
    [languages addObject:[self genLanguageWithName: @"C#" query: @"csharp"]];
    [languages addObject:[self genLanguageWithName: @"Objective-C" query: @"objective-c"]];
    [languages addObject:[self genLanguageWithName: @"R" query: @"r"]];
    [languages addObject:[self genLanguageWithName: @"VimL" query: @"vim"]];
    [languages addObject:[self genLanguageWithName: @"Go" query: @"go"]];
    [languages addObject:[self genLanguageWithName: @"Perl" query: @"perl"]];
    [languages addObject:[self genLanguageWithName: @"CoffeeScript" query: @"coffeescript"]];
    [languages addObject:[self genLanguageWithName: @"TeX" query: @"tex"]];
    [languages addObject:[self genLanguageWithName: @"Swift" query: @"swift"]];
    [languages addObject:[self genLanguageWithName: @"Scala" query: @"scala"]];
    [languages addObject:[self genLanguageWithName: @"Emacs Lisp" query: @"emacs-lisp"]];
    [languages addObject:[self genLanguageWithName: @"Haskell" query: @"haskell"]];
    [languages addObject:[self genLanguageWithName: @"Lua" query: @"lua"]];
    [languages addObject:[self genLanguageWithName: @"Clojure" query: @"clojure"]];
    [languages addObject:[self genLanguageWithName: @"Matlab" query: @"matlab"]];
    [languages addObject:[self genLanguageWithName: @"Arduino" query: @"arduino"]];
    [languages addObject:[self genLanguageWithName: @"Makefile" query: @"makefile"]];
    [languages addObject:[self genLanguageWithName: @"Groovy" query: @"groovy"]];
    [languages addObject:[self genLanguageWithName: @"Puppet" query: @"puppet"]];
    [languages addObject:[self genLanguageWithName: @"Rust" query: @"rust"]];
    [languages addObject:[self genLanguageWithName: @"PowerShell" query: @"powershell"]];


    [languages addObject:[self genLanguageWithName: @"1C Enterprise" query: @"1c-enterprise"]];
    [languages addObject:[self genLanguageWithName: @"ABAP" query: @"abap"]];
    [languages addObject:[self genLanguageWithName: @"ABNF" query: @"abnf"]];
    [languages addObject:[self genLanguageWithName: @"ActionScript" query: @"as3"]];
    [languages addObject:[self genLanguageWithName: @"Ada" query: @"ada"]];
    [languages addObject:[self genLanguageWithName: @"Agda" query: @"agda"]];
    [languages addObject:[self genLanguageWithName: @"AGS Script" query: @"ags-script"]];
    [languages addObject:[self genLanguageWithName: @"Alloy" query: @"alloy"]];
    [languages addObject:[self genLanguageWithName: @"Alpine Abuild" query: @"alpine-abuild"]];
    [languages addObject:[self genLanguageWithName: @"AMPL" query: @"ampl"]];
    [languages addObject:[self genLanguageWithName: @"Ant Build System" query: @"ant-build-system"]];
    [languages addObject:[self genLanguageWithName: @"ANTLR" query: @"antlr"]];
    [languages addObject:[self genLanguageWithName: @"ApacheConf" query: @"apacheconf"]];
    [languages addObject:[self genLanguageWithName: @"Apex" query: @"apex"]];
    [languages addObject:[self genLanguageWithName: @"API Blueprint" query: @"api-blueprint"]];
    [languages addObject:[self genLanguageWithName: @"APL" query: @"apl"]];
    [languages addObject:[self genLanguageWithName: @"Apollo Guidance Computer" query: @"apollo-guidance-computer"]];
    [languages addObject:[self genLanguageWithName: @"AppleScript" query: @"applescript"]];
    [languages addObject:[self genLanguageWithName: @"Arc" query: @"arc"]];
    [languages addObject:[self genLanguageWithName: @"AsciiDoc" query: @"asciidoc"]];
    [languages addObject:[self genLanguageWithName: @"ASN.1" query: @"asn.1"]];
    [languages addObject:[self genLanguageWithName: @"ASP" query: @"aspx-vb"]];
    [languages addObject:[self genLanguageWithName: @"AspectJ" query: @"aspectj"]];
    [languages addObject:[self genLanguageWithName: @"Assembly" query: @"nasm"]];
    [languages addObject:[self genLanguageWithName: @"ATS" query: @"ats"]];
    [languages addObject:[self genLanguageWithName: @"Augeas" query: @"augeas"]];
    [languages addObject:[self genLanguageWithName: @"AutoHotkey" query: @"autohotkey"]];
    [languages addObject:[self genLanguageWithName: @"AutoIt" query: @"autoit"]];
    [languages addObject:[self genLanguageWithName: @"Awk" query: @"awk"]];
    [languages addObject:[self genLanguageWithName: @"Batchfile" query: @"bat"]];
    [languages addObject:[self genLanguageWithName: @"Befunge" query: @"befunge"]];
    [languages addObject:[self genLanguageWithName: @"Bison" query: @"bison"]];
    [languages addObject:[self genLanguageWithName: @"BitBake" query: @"bitbake"]];
    [languages addObject:[self genLanguageWithName: @"Blade" query: @"blade"]];
    [languages addObject:[self genLanguageWithName: @"BlitzBasic" query: @"blitzbasic"]];
    [languages addObject:[self genLanguageWithName: @"BlitzMax" query: @"blitzmax"]];
    [languages addObject:[self genLanguageWithName: @"Bluespec" query: @"bluespec"]];
    [languages addObject:[self genLanguageWithName: @"Boo" query: @"boo"]];
    [languages addObject:[self genLanguageWithName: @"Brainfuck" query: @"brainfuck"]];
    [languages addObject:[self genLanguageWithName: @"Brightscript" query: @"brightscript"]];
    [languages addObject:[self genLanguageWithName: @"Bro" query: @"bro"]];
    [languages addObject:[self genLanguageWithName: @"C-ObjDump" query: @"c-objdump"]];
    [languages addObject:[self genLanguageWithName: @"C2hs Haskell" query: @"c2hs-haskell"]];
    [languages addObject:[self genLanguageWithName: @"Cap'n Proto" query: @"cap'n-proto"]];
    [languages addObject:[self genLanguageWithName: @"CartoCSS" query: @"cartocss"]];
    [languages addObject:[self genLanguageWithName: @"Ceylon" query: @"ceylon"]];
    [languages addObject:[self genLanguageWithName: @"Chapel" query: @"chapel"]];
    [languages addObject:[self genLanguageWithName: @"Charity" query: @"charity"]];
    [languages addObject:[self genLanguageWithName: @"ChucK" query: @"chuck"]];
    [languages addObject:[self genLanguageWithName: @"Cirru" query: @"cirru"]];
    [languages addObject:[self genLanguageWithName: @"Clarion" query: @"clarion"]];
    [languages addObject:[self genLanguageWithName: @"Clean" query: @"clean"]];
    [languages addObject:[self genLanguageWithName: @"Click" query: @"click"]];
    [languages addObject:[self genLanguageWithName: @"CLIPS" query: @"clips"]];
    [languages addObject:[self genLanguageWithName: @"CMake" query: @"cmake"]];
    [languages addObject:[self genLanguageWithName: @"COBOL" query: @"cobol"]];
    [languages addObject:[self genLanguageWithName: @"ColdFusion" query: @"cfm"]];
    [languages addObject:[self genLanguageWithName: @"ColdFusion CFC" query: @"cfc"]];
    [languages addObject:[self genLanguageWithName: @"COLLADA" query: @"collada"]];
    [languages addObject:[self genLanguageWithName: @"Common Lisp" query: @"common-lisp"]];
    [languages addObject:[self genLanguageWithName: @"Component Pascal" query: @"component-pascal"]];
    [languages addObject:[self genLanguageWithName: @"Cool" query: @"cool"]];
    [languages addObject:[self genLanguageWithName: @"Coq" query: @"coq"]];
    [languages addObject:[self genLanguageWithName: @"Cpp-ObjDump" query: @"cpp-objdump"]];
    [languages addObject:[self genLanguageWithName: @"Creole" query: @"creole"]];
    [languages addObject:[self genLanguageWithName: @"Crystal" query: @"crystal"]];
    [languages addObject:[self genLanguageWithName: @"CSON" query: @"cson"]];
    [languages addObject:[self genLanguageWithName: @"Csound" query: @"csound"]];
    [languages addObject:[self genLanguageWithName: @"Csound Document" query: @"csound-document"]];
    [languages addObject:[self genLanguageWithName: @"Csound Score" query: @"csound-score"]];
    [languages addObject:[self genLanguageWithName: @"CSV" query: @"csv"]];
    [languages addObject:[self genLanguageWithName: @"Cucumber" query: @"cucumber"]];
    [languages addObject:[self genLanguageWithName: @"Cuda" query: @"cuda"]];
    [languages addObject:[self genLanguageWithName: @"Cycript" query: @"cycript"]];
    [languages addObject:[self genLanguageWithName: @"Cython" query: @"cython"]];
    [languages addObject:[self genLanguageWithName: @"D" query: @"d"]];
    [languages addObject:[self genLanguageWithName: @"D-ObjDump" query: @"d-objdump"]];
    [languages addObject:[self genLanguageWithName: @"Darcs Patch" query: @"dpatch"]];
    [languages addObject:[self genLanguageWithName: @"Dart" query: @"dart"]];
    [languages addObject:[self genLanguageWithName: @"Diff" query: @"diff"]];
    [languages addObject:[self genLanguageWithName: @"DIGITAL Command Language" query: @"digital-command-language"]];
    [languages addObject:[self genLanguageWithName: @"DM" query: @"dm"]];
    [languages addObject:[self genLanguageWithName: @"DNS Zone" query: @"dns-zone"]];
    [languages addObject:[self genLanguageWithName: @"Dockerfile" query: @"dockerfile"]];
    [languages addObject:[self genLanguageWithName: @"Dogescript" query: @"dogescript"]];
    [languages addObject:[self genLanguageWithName: @"Graphviz (DOT)" query: @"graphviz-(dot)"]];
    [languages addObject:[self genLanguageWithName: @"DTrace" query: @"dtrace"]];
    [languages addObject:[self genLanguageWithName: @"Dylan" query: @"dylan"]];
    [languages addObject:[self genLanguageWithName: @"E" query: @"e"]];
    [languages addObject:[self genLanguageWithName: @"Eagle" query: @"eagle"]];
    [languages addObject:[self genLanguageWithName: @"EBNF" query: @"ebnf"]];
    [languages addObject:[self genLanguageWithName: @"eC" query: @"ec"]];
    [languages addObject:[self genLanguageWithName: @"Ecere Projects" query: @"ecere-projects"]];
    [languages addObject:[self genLanguageWithName: @"ECL" query: @"ecl"]];
    [languages addObject:[self genLanguageWithName: @"ECLiPSe" query: @"eclipse"]];
    [languages addObject:[self genLanguageWithName: @"Eiffel" query: @"eiffel"]];
    [languages addObject:[self genLanguageWithName: @"EJS" query: @"ejs"]];
    [languages addObject:[self genLanguageWithName: @"Elixir" query: @"elixir"]];
    [languages addObject:[self genLanguageWithName: @"Elm" query: @"elm"]];
    [languages addObject:[self genLanguageWithName: @"EmberScript" query: @"emberscript"]];
    [languages addObject:[self genLanguageWithName: @"EQ" query: @"eq"]];
    [languages addObject:[self genLanguageWithName: @"Erlang" query: @"erlang"]];
    [languages addObject:[self genLanguageWithName: @"F#" query: @"fsharp"]];
    [languages addObject:[self genLanguageWithName: @"Factor" query: @"factor"]];
    [languages addObject:[self genLanguageWithName: @"Fancy" query: @"fancy"]];
    [languages addObject:[self genLanguageWithName: @"Fantom" query: @"fantom"]];
    [languages addObject:[self genLanguageWithName: @"Filebench WML" query: @"filebench-wml"]];
    [languages addObject:[self genLanguageWithName: @"Filterscript" query: @"filterscript"]];
    [languages addObject:[self genLanguageWithName: @"FLUX" query: @"flux"]];
    [languages addObject:[self genLanguageWithName: @"Formatted" query: @"formatted"]];
    [languages addObject:[self genLanguageWithName: @"Forth" query: @"forth"]];
    [languages addObject:[self genLanguageWithName: @"FORTRAN" query: @"fortran"]];
    [languages addObject:[self genLanguageWithName: @"FreeMarker" query: @"freemarker"]];
    [languages addObject:[self genLanguageWithName: @"Frege" query: @"frege"]];
    [languages addObject:[self genLanguageWithName: @"G-code" query: @"g-code"]];
    [languages addObject:[self genLanguageWithName: @"Game Maker Language" query: @"game-maker-language"]];
    [languages addObject:[self genLanguageWithName: @"GAMS" query: @"gams"]];
    [languages addObject:[self genLanguageWithName: @"GAP" query: @"gap"]];
    [languages addObject:[self genLanguageWithName: @"GAS" query: @"gas"]];
    [languages addObject:[self genLanguageWithName: @"GCC Machine Description" query: @"gcc-machine-description"]];
    [languages addObject:[self genLanguageWithName: @"GDB" query: @"gdb"]];
    [languages addObject:[self genLanguageWithName: @"GDScript" query: @"gdscript"]];
    [languages addObject:[self genLanguageWithName: @"Genshi" query: @"genshi"]];
    [languages addObject:[self genLanguageWithName: @"Gentoo Ebuild" query: @"gentoo-ebuild"]];
    [languages addObject:[self genLanguageWithName: @"Gentoo Eclass" query: @"gentoo-eclass"]];
    [languages addObject:[self genLanguageWithName: @"Gettext Catalog" query: @"pot"]];
    [languages addObject:[self genLanguageWithName: @"GLSL" query: @"glsl"]];
    [languages addObject:[self genLanguageWithName: @"Glyph" query: @"glyph"]];
    [languages addObject:[self genLanguageWithName: @"GN" query: @"gn"]];
    [languages addObject:[self genLanguageWithName: @"Gnuplot" query: @"gnuplot"]];
    [languages addObject:[self genLanguageWithName: @"Golo" query: @"golo"]];
    [languages addObject:[self genLanguageWithName: @"Gosu" query: @"gosu"]];
    [languages addObject:[self genLanguageWithName: @"Grace" query: @"grace"]];
    [languages addObject:[self genLanguageWithName: @"Gradle" query: @"gradle"]];
    [languages addObject:[self genLanguageWithName: @"Grammatical Framework" query: @"grammatical-framework"]];
    [languages addObject:[self genLanguageWithName: @"Graph Modeling Language" query: @"graph-modeling-language"]];
    [languages addObject:[self genLanguageWithName: @"GraphQL" query: @"graphql"]];
    [languages addObject:[self genLanguageWithName: @"Groff" query: @"groff"]];
    [languages addObject:[self genLanguageWithName: @"Groovy Server Pages" query: @"groovy-server-pages"]];
    [languages addObject:[self genLanguageWithName: @"Hack" query: @"hack"]];
    [languages addObject:[self genLanguageWithName: @"Haml" query: @"haml"]];
    [languages addObject:[self genLanguageWithName: @"Handlebars" query: @"handlebars"]];
    [languages addObject:[self genLanguageWithName: @"Harbour" query: @"harbour"]];
    [languages addObject:[self genLanguageWithName: @"Haxe" query: @"haxe"]];
    [languages addObject:[self genLanguageWithName: @"HCL" query: @"hcl"]];
    [languages addObject:[self genLanguageWithName: @"HLSL" query: @"hlsl"]];
    [languages addObject:[self genLanguageWithName: @"HTML" query: @"html"]];
    [languages addObject:[self genLanguageWithName: @"HTML+Django" query: @"html+django"]];
    [languages addObject:[self genLanguageWithName: @"HTML+ECR" query: @"html+ecr"]];
    [languages addObject:[self genLanguageWithName: @"HTML+EEX" query: @"html+eex"]];
    [languages addObject:[self genLanguageWithName: @"HTML+ERB" query: @"html+erb"]];
    [languages addObject:[self genLanguageWithName: @"HTML+PHP" query: @"html+php"]];
    [languages addObject:[self genLanguageWithName: @"HTTP" query: @"http"]];
    [languages addObject:[self genLanguageWithName: @"Hy" query: @"hy"]];
    [languages addObject:[self genLanguageWithName: @"HyPhy" query: @"hyphy"]];
    [languages addObject:[self genLanguageWithName: @"IDL" query: @"idl"]];
    [languages addObject:[self genLanguageWithName: @"Idris" query: @"idris"]];
    [languages addObject:[self genLanguageWithName: @"IGOR Pro" query: @"igor-pro"]];
    [languages addObject:[self genLanguageWithName: @"Inform 7" query: @"inform-7"]];
    [languages addObject:[self genLanguageWithName: @"INI" query: @"ini"]];
    [languages addObject:[self genLanguageWithName: @"Inno Setup" query: @"inno-setup"]];
    [languages addObject:[self genLanguageWithName: @"Io" query: @"io"]];
    [languages addObject:[self genLanguageWithName: @"Ioke" query: @"ioke"]];
    [languages addObject:[self genLanguageWithName: @"IRC log" query: @"irc"]];
    [languages addObject:[self genLanguageWithName: @"Isabelle" query: @"isabelle"]];
    [languages addObject:[self genLanguageWithName: @"Isabelle ROOT" query: @"isabelle-root"]];
    [languages addObject:[self genLanguageWithName: @"J" query: @"j"]];
    [languages addObject:[self genLanguageWithName: @"Jade" query: @"jade"]];
    [languages addObject:[self genLanguageWithName: @"Jasmin" query: @"jasmin"]];
    [languages addObject:[self genLanguageWithName: @"Java Server Pages" query: @"jsp"]];
    [languages addObject:[self genLanguageWithName: @"JFlex" query: @"jflex"]];
    [languages addObject:[self genLanguageWithName: @"JSON" query: @"json"]];
    [languages addObject:[self genLanguageWithName: @"JSON5" query: @"json5"]];
    [languages addObject:[self genLanguageWithName: @"JSONiq" query: @"jsoniq"]];
    [languages addObject:[self genLanguageWithName: @"JSONLD" query: @"jsonld"]];
    [languages addObject:[self genLanguageWithName: @"JSX" query: @"jsx"]];
    [languages addObject:[self genLanguageWithName: @"Julia" query: @"julia"]];
    [languages addObject:[self genLanguageWithName: @"Jupyter Notebook" query: @"jupyter-notebook"]];
    [languages addObject:[self genLanguageWithName: @"KiCad" query: @"kicad"]];
    [languages addObject:[self genLanguageWithName: @"Kit" query: @"kit"]];
    [languages addObject:[self genLanguageWithName: @"Kotlin" query: @"kotlin"]];
    [languages addObject:[self genLanguageWithName: @"KRL" query: @"krl"]];
    [languages addObject:[self genLanguageWithName: @"LabVIEW" query: @"labview"]];
    [languages addObject:[self genLanguageWithName: @"Lasso" query: @"lasso"]];
    [languages addObject:[self genLanguageWithName: @"Lean" query: @"lean"]];
    [languages addObject:[self genLanguageWithName: @"Lex" query: @"lex"]];
    [languages addObject:[self genLanguageWithName: @"LilyPond" query: @"lilypond"]];
    [languages addObject:[self genLanguageWithName: @"Limbo" query: @"limbo"]];
    [languages addObject:[self genLanguageWithName: @"Liquid" query: @"liquid"]];
    [languages addObject:[self genLanguageWithName: @"LiveScript" query: @"livescript"]];
    [languages addObject:[self genLanguageWithName: @"LLVM" query: @"llvm"]];
    [languages addObject:[self genLanguageWithName: @"Logos" query: @"logos"]];
    [languages addObject:[self genLanguageWithName: @"Logtalk" query: @"logtalk"]];
    [languages addObject:[self genLanguageWithName: @"LOLCODE" query: @"lolcode"]];
    [languages addObject:[self genLanguageWithName: @"LookML" query: @"lookml"]];
    [languages addObject:[self genLanguageWithName: @"LoomScript" query: @"loomscript"]];
    [languages addObject:[self genLanguageWithName: @"LSL" query: @"lsl"]];
    [languages addObject:[self genLanguageWithName: @"M" query: @"m"]];
    [languages addObject:[self genLanguageWithName: @"M4" query: @"m4"]];
    [languages addObject:[self genLanguageWithName: @"Mako" query: @"mako"]];
    [languages addObject:[self genLanguageWithName: @"Markdown" query: @"markdown"]];
    [languages addObject:[self genLanguageWithName: @"Mask" query: @"mask"]];
    [languages addObject:[self genLanguageWithName: @"Mathematica" query: @"mathematica"]];
    [languages addObject:[self genLanguageWithName: @"Max" query: @"max/msp"]];
    [languages addObject:[self genLanguageWithName: @"MAXScript" query: @"maxscript"]];
    [languages addObject:[self genLanguageWithName: @"Mercury" query: @"mercury"]];
    [languages addObject:[self genLanguageWithName: @"Metal" query: @"metal"]];
    [languages addObject:[self genLanguageWithName: @"MiniD" query: @"minid"]];
    [languages addObject:[self genLanguageWithName: @"Mirah" query: @"mirah"]];
    [languages addObject:[self genLanguageWithName: @"Modelica" query: @"modelica"]];
    [languages addObject:[self genLanguageWithName: @"Modula-2" query: @"modula-2"]];
    [languages addObject:[self genLanguageWithName: @"Module Management System" query: @"module-management-system"]];
    [languages addObject:[self genLanguageWithName: @"Monkey" query: @"monkey"]];
    [languages addObject:[self genLanguageWithName: @"Moocode" query: @"moocode"]];
    [languages addObject:[self genLanguageWithName: @"MoonScript" query: @"moonscript"]];
    [languages addObject:[self genLanguageWithName: @"MQL4" query: @"mql4"]];
    [languages addObject:[self genLanguageWithName: @"MQL5" query: @"mql5"]];
    [languages addObject:[self genLanguageWithName: @"MTML" query: @"mtml"]];
    [languages addObject:[self genLanguageWithName: @"mupad" query: @"mupad"]];
    [languages addObject:[self genLanguageWithName: @"Myghty" query: @"myghty"]];
    [languages addObject:[self genLanguageWithName: @"NCL" query: @"ncl"]];
    [languages addObject:[self genLanguageWithName: @"Nemerle" query: @"nemerle"]];
    [languages addObject:[self genLanguageWithName: @"nesC" query: @"nesc"]];
    [languages addObject:[self genLanguageWithName: @"NetLinx" query: @"netlinx"]];
    [languages addObject:[self genLanguageWithName: @"NetLinx+ERB" query: @"netlinx+erb"]];
    [languages addObject:[self genLanguageWithName: @"NetLogo" query: @"netlogo"]];
    [languages addObject:[self genLanguageWithName: @"NewLisp" query: @"newlisp"]];
    [languages addObject:[self genLanguageWithName: @"Nginx" query: @"nginx"]];
    [languages addObject:[self genLanguageWithName: @"Nimrod" query: @"nimrod"]];
    [languages addObject:[self genLanguageWithName: @"Nit" query: @"nit"]];
    [languages addObject:[self genLanguageWithName: @"Nix" query: @"nix"]];
    [languages addObject:[self genLanguageWithName: @"NSIS" query: @"nsis"]];
    [languages addObject:[self genLanguageWithName: @"Nu" query: @"nu"]];
    [languages addObject:[self genLanguageWithName: @"Objective-C++" query: @"objective-c++"]];
    [languages addObject:[self genLanguageWithName: @"Objective-J" query: @"objective-j"]];
    [languages addObject:[self genLanguageWithName: @"OCaml" query: @"ocaml"]];
    [languages addObject:[self genLanguageWithName: @"Omgrofl" query: @"omgrofl"]];
    [languages addObject:[self genLanguageWithName: @"ooc" query: @"ooc"]];
    [languages addObject:[self genLanguageWithName: @"Opa" query: @"opa"]];
    [languages addObject:[self genLanguageWithName: @"Opal" query: @"opal"]];
    [languages addObject:[self genLanguageWithName: @"OpenEdge ABL" query: @"openedge-abl"]];
    [languages addObject:[self genLanguageWithName: @"OpenType Feature File" query: @"opentype-feature-file"]];
    [languages addObject:[self genLanguageWithName: @"Ox" query: @"ox"]];
    [languages addObject:[self genLanguageWithName: @"Oxygene" query: @"oxygene"]];
    [languages addObject:[self genLanguageWithName: @"Oz" query: @"oz"]];
    [languages addObject:[self genLanguageWithName: @"Pan" query: @"pan"]];
    [languages addObject:[self genLanguageWithName: @"Papyrus" query: @"papyrus"]];
    [languages addObject:[self genLanguageWithName: @"Parrot" query: @"parrot"]];
    [languages addObject:[self genLanguageWithName: @"Pascal" query: @"pascal"]];
    [languages addObject:[self genLanguageWithName: @"PAWN" query: @"pawn"]];
    [languages addObject:[self genLanguageWithName: @"Perl6" query: @"perl6"]];
    [languages addObject:[self genLanguageWithName: @"PicoLisp" query: @"picolisp"]];
    [languages addObject:[self genLanguageWithName: @"PigLatin" query: @"piglatin"]];
    [languages addObject:[self genLanguageWithName: @"Pike" query: @"pike"]];
    [languages addObject:[self genLanguageWithName: @"PLpgSQL" query: @"plpgsql"]];
    [languages addObject:[self genLanguageWithName: @"PLSQL" query: @"plsql"]];
    [languages addObject:[self genLanguageWithName: @"PogoScript" query: @"pogoscript"]];
    [languages addObject:[self genLanguageWithName: @"Pony" query: @"pony"]];
    [languages addObject:[self genLanguageWithName: @"PostScript" query: @"postscript"]];
    [languages addObject:[self genLanguageWithName: @"POV-Ray SDL" query: @"pov-ray-sdl"]];
    [languages addObject:[self genLanguageWithName: @"PowerBuilder" query: @"powerbuilder"]];
    [languages addObject:[self genLanguageWithName: @"Processing" query: @"processing"]];
    [languages addObject:[self genLanguageWithName: @"Prolog" query: @"prolog"]];
    [languages addObject:[self genLanguageWithName: @"Propeller Spin" query: @"propeller-spin"]];
    [languages addObject:[self genLanguageWithName: @"Protocol Buffer" query: @"protocol-buffer"]];
    [languages addObject:[self genLanguageWithName: @"Pure Data" query: @"pure-data"]];
    [languages addObject:[self genLanguageWithName: @"PureBasic" query: @"purebasic"]];
    [languages addObject:[self genLanguageWithName: @"PureScript" query: @"purescript"]];
    [languages addObject:[self genLanguageWithName: @"QMake" query: @"qmake"]];
    [languages addObject:[self genLanguageWithName: @"QML" query: @"qml"]];
    [languages addObject:[self genLanguageWithName: @"Racket" query: @"racket"]];
    [languages addObject:[self genLanguageWithName: @"Ragel in Ruby Host" query: @"ragel-in-ruby-host"]];
    [languages addObject:[self genLanguageWithName: @"RAML" query: @"raml"]];
    [languages addObject:[self genLanguageWithName: @"Rascal" query: @"rascal"]];
    [languages addObject:[self genLanguageWithName: @"RDoc" query: @"rdoc"]];
    [languages addObject:[self genLanguageWithName: @"REALbasic" query: @"realbasic"]];
    [languages addObject:[self genLanguageWithName: @"Rebol" query: @"rebol"]];
    [languages addObject:[self genLanguageWithName: @"Red" query: @"red"]];
    [languages addObject:[self genLanguageWithName: @"Redcode" query: @"redcode"]];
    [languages addObject:[self genLanguageWithName: @"Ren'Py" query: @"ren'py"]];
    [languages addObject:[self genLanguageWithName: @"RenderScript" query: @"renderscript"]];
    [languages addObject:[self genLanguageWithName: @"REXX" query: @"rexx"]];
    [languages addObject:[self genLanguageWithName: @"RobotFramework" query: @"robotframework"]];
    [languages addObject:[self genLanguageWithName: @"Rouge" query: @"rouge"]];
    [languages addObject:[self genLanguageWithName: @"RUNOFF" query: @"runoff"]];
    [languages addObject:[self genLanguageWithName: @"SaltStack" query: @"saltstack"]];
    [languages addObject:[self genLanguageWithName: @"SAS" query: @"sas"]];
    [languages addObject:[self genLanguageWithName: @"Scheme" query: @"scheme"]];
    [languages addObject:[self genLanguageWithName: @"Scilab" query: @"scilab"]];
    [languages addObject:[self genLanguageWithName: @"Self" query: @"self"]];
    [languages addObject:[self genLanguageWithName: @"ShellSession" query: @"shellsession"]];
    [languages addObject:[self genLanguageWithName: @"Shen" query: @"shen"]];
    [languages addObject:[self genLanguageWithName: @"Slash" query: @"slash"]];
    [languages addObject:[self genLanguageWithName: @"Smali" query: @"smali"]];
    [languages addObject:[self genLanguageWithName: @"Smalltalk" query: @"smalltalk"]];
    [languages addObject:[self genLanguageWithName: @"Smarty" query: @"smarty"]];
    [languages addObject:[self genLanguageWithName: @"SMT" query: @"smt"]];
    [languages addObject:[self genLanguageWithName: @"Spline Font Database" query: @"spline-font-database"]];
    [languages addObject:[self genLanguageWithName: @"SQF" query: @"sqf"]];
    [languages addObject:[self genLanguageWithName: @"SQL" query: @"sql"]];
    [languages addObject:[self genLanguageWithName: @"SQLPL" query: @"sqlpl"]];
    [languages addObject:[self genLanguageWithName: @"Squirrel" query: @"squirrel"]];
    [languages addObject:[self genLanguageWithName: @"SRecode Template" query: @"srecode-template"]];
    [languages addObject:[self genLanguageWithName: @"Stan" query: @"stan"]];
    [languages addObject:[self genLanguageWithName: @"Standard ML" query: @"standard-ml"]];
    [languages addObject:[self genLanguageWithName: @"Stata" query: @"stata"]];
    [languages addObject:[self genLanguageWithName: @"SuperCollider" query: @"supercollider"]];
    [languages addObject:[self genLanguageWithName: @"SystemVerilog" query: @"systemverilog"]];
    [languages addObject:[self genLanguageWithName: @"Tcl" query: @"tcl"]];
    [languages addObject:[self genLanguageWithName: @"Tea" query: @"tea"]];
    [languages addObject:[self genLanguageWithName: @"Terra" query: @"terra"]];
    [languages addObject:[self genLanguageWithName: @"Thrift" query: @"thrift"]];
    [languages addObject:[self genLanguageWithName: @"TI Program" query: @"ti-program"]];
    [languages addObject:[self genLanguageWithName: @"TLA" query: @"tla"]];
    [languages addObject:[self genLanguageWithName: @"Turing" query: @"turing"]];
    [languages addObject:[self genLanguageWithName: @"TXL" query: @"txl"]];
    [languages addObject:[self genLanguageWithName: @"TypeScript" query: @"typescript"]];
    [languages addObject:[self genLanguageWithName: @"Uno" query: @"uno"]];
    [languages addObject:[self genLanguageWithName: @"UnrealScript" query: @"unrealscript"]];
    [languages addObject:[self genLanguageWithName: @"UrWeb" query: @"urweb"]];
    [languages addObject:[self genLanguageWithName: @"Vala" query: @"vala"]];
    [languages addObject:[self genLanguageWithName: @"VCL" query: @"vcl"]];
    [languages addObject:[self genLanguageWithName: @"Verilog" query: @"verilog"]];
    [languages addObject:[self genLanguageWithName: @"VHDL" query: @"vhdl"]];
    [languages addObject:[self genLanguageWithName: @"Visual Basic" query: @"visual-basic"]];
    [languages addObject:[self genLanguageWithName: @"Volt" query: @"volt"]];
    [languages addObject:[self genLanguageWithName: @"Vue" query: @"vue"]];
    [languages addObject:[self genLanguageWithName: @"Web Ontology Language" query: @"web-ontology-language"]];
    [languages addObject:[self genLanguageWithName: @"WebIDL" query: @"webidl"]];
    [languages addObject:[self genLanguageWithName: @"wisp" query: @"wisp"]];
    [languages addObject:[self genLanguageWithName: @"X10" query: @"x10"]];
    [languages addObject:[self genLanguageWithName: @"xBase" query: @"xbase"]];
    [languages addObject:[self genLanguageWithName: @"XC" query: @"xc"]];
    [languages addObject:[self genLanguageWithName: @"XML" query: @"xml"]];
    [languages addObject:[self genLanguageWithName: @"Xojo" query: @"xojo"]];
    [languages addObject:[self genLanguageWithName: @"XPages" query: @"xpages"]];
    [languages addObject:[self genLanguageWithName: @"XProc" query: @"xproc"]];
    [languages addObject:[self genLanguageWithName: @"XQuery" query: @"xquery"]];
    [languages addObject:[self genLanguageWithName: @"XS" query: @"xs"]];
    [languages addObject:[self genLanguageWithName: @"XSLT" query: @"xslt"]];
    [languages addObject:[self genLanguageWithName: @"Xtend" query: @"xtend"]];
    [languages addObject:[self genLanguageWithName: @"Yacc" query: @"yacc"]];
    [languages addObject:[self genLanguageWithName: @"Zephir" query: @"zephir"]];
    [languages addObject:[self genLanguageWithName: @"Zimpl" query: @"zimpl"]];

    return languages;
}

#pragma mark - archive

- (NSString *) archivePath
{
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths firstObject];

    return [docPath stringByAppendingPathComponent:@"languages.data"];
}

- (BOOL) saveLanguages
{
    NSString *writePath = [self archivePath];
    BOOL written = [NSKeyedArchiver archiveRootObject:self.languages toFile:writePath];

    return written;
}

- (NSMutableArray *) readLanguages
{
    NSString *path = [self archivePath];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

@end
