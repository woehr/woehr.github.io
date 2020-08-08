{-# LANGUAGE OverloadedStrings #-}

import           Hakyll

--import           Data.Monoid        (mappend)
import           System.Environment (lookupEnv)

defaultContextWithDate :: Context String
defaultContextWithDate =
    dateField "date" "%B %e, %Y" <>
    defaultContext

main :: IO ()
main = do
  providerEnv <- lookupEnv "HAKYLL_PROVIDER_DIR"
  let provider = case providerEnv of
                   Just p  -> p
                   Nothing -> "./content"

  hakyllWith (defaultConfiguration { providerDirectory = provider }) $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.md", "contact.md"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/**" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    defaultContextWithDate
            >>= loadAndApplyTemplate "templates/default.html" defaultContextWithDate
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- loadAll (fromRegex "posts/(blog|books|technical)/*") >>= recentFirst
            let archiveCtx =
                    listField "posts" defaultContextWithDate (return posts) <>
                    constField "title" "Archives" <>
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            let loadAndCompilePostList :: Pattern -> Bool -> Compiler (Maybe (Item String))
                loadAndCompilePostList dirPattern hasDates = do
                    posts <- loadAll dirPattern >>= \p -> if hasDates then recentFirst p else return p
                    let ctx = if hasDates then defaultContextWithDate else defaultContext
                    let postListCtx = listField "posts" ctx (return posts) <> ctx
                    if length posts > 0
                        then makeItem "" >>= loadAndApplyTemplate "templates/post-list.html" postListCtx >>= return . Just
                        else return Nothing

            postsBlog <- loadAndCompilePostList "posts/blog/*" True
            postsTech <- loadAndCompilePostList "posts/technical/*" True
            postsBook <- loadAndCompilePostList "posts/books/*" True
            postsInProgress <- loadAndCompilePostList "posts/inprogress/*" False



            let indexCtx =
                    maybe mempty (constField "postsBlog" . itemBody) postsBlog <>
                    maybe mempty (constField "postsTech" . itemBody) postsTech <>
                    maybe mempty (constField "postsBook" . itemBody) postsBook <>
                    maybe mempty (constField "postsInProgress" . itemBody) postsInProgress <>
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler
