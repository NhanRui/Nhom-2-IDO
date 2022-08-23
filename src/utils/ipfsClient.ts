import { create } from 'ipfs-http-client'

export const IPFSClient = create({ host: "seaweed.infura-ipfs.io", port: 5001, protocol: "https" })
console.log(process.env.REACT_APP_PROJECT_ID)
export const IPFSClientApiEndpoint = create({ 
    host: "ipfs.infura.io", 
    port: 5001, 
    protocol: "https",
    headers: {
        authorization: "Basic " + Buffer.from(process.env.REACT_APP_PROJECT_ID + ':' + process.env.REACT_APP_PROJECT_SECRET).toString('base64')
    }
})