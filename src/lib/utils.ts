export function asyncDebounce<A extends unknown[], R>(
  fn: (...args: A) => Promise<R>,
  wait: number
): (...args: A) => Promise<R> {
  let lastTimeoutId: ReturnType<typeof setTimeout> | undefined = undefined

  return (...args: A): Promise<R> => {
    clearTimeout(lastTimeoutId)

    return new Promise((resolve, reject) => {
      const currentTimeoutId = setTimeout(async () => {
        try {
          if (currentTimeoutId === lastTimeoutId) {
            const result = await fn(...args)
            resolve(result)
          }
        } catch (err) {
          reject(err)
        }
      }, wait)

      lastTimeoutId = currentTimeoutId
    })
  }
}

export const extractSearchParam = (url: URL, param: string): string | null => {
  const val = url.searchParams.get(param)

  // clear the param from the URL
  url.searchParams.delete(param)
  history.replaceState(null, document.title, url.toString())

  return val
}

/**
 * File to Uint8Array
 */
export async function fileToUint8Array(file: File): Promise<Uint8Array> {
  return new Uint8Array(
    await new Blob([ file ]).arrayBuffer()
  )
}

/**
 * Slugify a string
 */

export const slugify = (str: string): string => {
  const slug = String(str)
    .normalize('NFKD') // split accented characters into their base characters and diacritical marks
    .replace(/[\u0300-\u036f]/g, '') // remove all the accents, which happen to be all in the \u03xx UNICODE block.
    .trim() // trim leading or trailing whitespace
    .toLowerCase() // convert to lowercase
    .replace(/[^a-z0-9 -]/g, '') // remove non-alphanumeric characters
    .replace(/\s+/g, '-') // replace spaces with hyphens
    .replace(/-+/g, '-') // remove consecutive hyphens

  return slug
}
