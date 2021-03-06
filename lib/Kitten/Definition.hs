{-|
Module      : Kitten.Definition
Description : Definitions of words, instances, and permissions
Copyright   : (c) Jon Purdy, 2016
License     : MIT
Maintainer  : evincarofautumn@gmail.com
Stability   : experimental
Portability : GHC
-}

{-# LANGUAGE OverloadedStrings #-}

module Kitten.Definition
  ( Definition(..)
  , isMain
  , main
  , mainName
  ) where

import Data.Maybe (fromMaybe)
import Kitten.Entry.Category (Category)
import Kitten.Entry.Merge (Merge)
import Kitten.Entry.Parameter (Parameter(..))
import Kitten.Entry.Parent (Parent)
import Kitten.Kind (Kind(..))
import Kitten.Name (GeneralName(..), Qualified(..))
import Kitten.Operator (Fixity)
import Kitten.Origin (Origin)
import Kitten.Signature (Signature)
import Kitten.Term (Term)
import Text.PrettyPrint.HughesPJClass (Pretty(..))
import qualified Kitten.Entry.Category as Category
import qualified Kitten.Entry.Merge as Merge
import qualified Kitten.Operator as Operator
import qualified Kitten.Pretty as Pretty
import qualified Kitten.Signature as Signature
import qualified Kitten.Term as Term
import qualified Kitten.Token as Token
import qualified Kitten.Vocabulary as Vocabulary

data Definition a = Definition
  { body :: !(Term a)
  , category :: !Category
  , fixity :: !Fixity
  , inferSignature :: !Bool
  , merge :: !Merge
  , name :: !Qualified
  , origin :: !Origin
  , parent :: !(Maybe Parent)
  , signature :: !Signature
  } deriving (Show)

instance Pretty (Definition a) where
  pPrint definition = Pretty.asDefinition
    (pPrint $ name definition)
    (pPrint $ signature definition)
    (pPrint $ body definition)
    (pPrint Token.Define)

-- | The main definition, created implicitly from top-level code in program
-- fragments.

main
  :: [GeneralName]
  -- ^ List of permissions implicitly granted.
  -> Maybe Qualified
  -- ^ Override default name.
  -> Term a
  -- ^ Body.
  -> Definition a
main permissions mName term = Definition
  { body = term
  , category = Category.Word
  , fixity = Operator.Postfix
  , inferSignature = True
  , merge = Merge.Compose
  , name = fromMaybe mainName mName
  , origin = o
  , parent = Nothing
  , signature = Signature.Quantified
    [Parameter o "R" Stack]
    (Signature.StackFunction
      (Signature.Variable "R" o) []
      (Signature.Variable "R" o) []
      permissions o) o
  }
  where o = Term.origin term

-- | Default name of main definition.

mainName :: Qualified
mainName = Qualified Vocabulary.global "main"

-- | Whether a given definition refers to (the default-named) @main@.

isMain :: Definition a -> Bool
isMain = (== Qualified Vocabulary.global "main") . name
