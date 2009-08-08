
module HSE.All(
    module Language.Haskell.Exts,
    module HSE.Util, module HSE.Evaluate,
    module HSE.Bracket, module HSE.Match,
    module HSE.Generics,
    module HSE.NameMatch,
    parseFile, parseString, fromParseResult
    ) where

import Language.Haskell.Exts hiding (parse, parseFile, paren, fromParseResult)
import qualified Language.Haskell.Exts as HSE

import HSE.Util
import HSE.Evaluate
import HSE.Generics
import HSE.Bracket
import HSE.Match
import HSE.NameMatch
import Util
import Data.Char
import Data.List
import Language.Preprocessor.Cpphs


-- | Parse a Haskell module
parseString :: Bool -> FilePath -> String -> ParseResult Module
parseString implies file = parseFileContentsWithMode mode . runCpphs opts file
    where
        opts = defaultCpphsOptions{boolopts=defaultBoolOptions{locations=False}}

        mode = defaultParseMode
            {parseFilename = file
            ,extensions = extension
            ,fixities = concat [infix_ (-1) ["==>"] | implies] ++ baseFixities
            }


-- | On failure returns an empty module and prints to the console
parseFile :: Bool -> FilePath -> IO (ParseResult Module)
parseFile implies file = do
    src <- readFile file
    return $ parseString implies file src


-- | TODO: Use the fromParseResult in HSE once it gives source location
fromParseResult :: ParseResult Module -> Module
fromParseResult (ParseOk x) = x
fromParseResult (ParseFailed src msg) = error $ showSrcLoc src ++ " Parse failure, " ++ limit 50 msg


extension =
    [OverlappingInstances, UndecidableInstances, IncoherentInstances, RecursiveDo
    ,ParallelListComp, MultiParamTypeClasses, NoMonomorphismRestriction, FunctionalDependencies
    ,Rank2Types, RankNTypes, PolymorphicComponents, ExistentialQuantification, ScopedTypeVariables
    ,ImplicitParams,FlexibleContexts,FlexibleInstances,EmptyDataDecls
    -- NOT: CPP
    ,KindSignatures,BangPatterns,TypeSynonymInstances,TemplateHaskell
    ,ForeignFunctionInterface,Generics,NoImplicitPrelude,NamedFieldPuns,PatternGuards
    ,GeneralizedNewtypeDeriving,ExtensibleRecords,RestrictedTypeSynonyms,HereDocuments
    ,MagicHash,TypeFamilies,StandaloneDeriving,UnicodeSyntax,PatternSignatures,UnliftedFFITypes
    ,LiberalTypeSynonyms,TypeOperators,RecordWildCards,RecordPuns,DisambiguateRecordFields
    ,OverloadedStrings,GADTs,MonoPatBinds,RelaxedPolyRec,ExtendedDefaultRules,UnboxedTuples
    ,DeriveDataTypeable,ConstrainedClassMethods,PackageImports,ImpredicativeTypes
    ,NewQualifiedOperators,PostfixOperators,QuasiQuotes,ViewPatterns
    -- NOT: Arrows - steals proc
    -- NOT: TransformListComp - steals the group keyword
    -- NOT: XmlSyntax, RegularPatterns - steals a-b
    ]
