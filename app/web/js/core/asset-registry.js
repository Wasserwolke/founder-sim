export class AssetRegistry{
 constructor(data){this.data=data}
 static async fromUrl(url){return new AssetRegistry(await (await fetch(url)).json())}
 find(id){for(const group of Object.values(this.data)){if(group&&typeof group==="object"&&!Array.isArray(group)&&group[id])return group[id]}return null}
 resolve(id,variant="world"){if(variant==="icon"&&this.data.prototype_icons?.[id])return this.data.prototype_icons[id];const a=this.find(id);return typeof a==="string"?a:(a?.[variant]??null)}
 patch(id,patch){const a=this.find(id);if(a&&typeof a==="object")Object.assign(a,patch)}
}
